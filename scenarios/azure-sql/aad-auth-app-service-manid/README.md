# Azure SQL AAD Auth from App Service with Managed Identity

Key features:
* Demonstrates managed identity as a turn-key solution for securing access to Azure SQL Database from Azure App Service
* Eliminates secrets from the app tier
* Builds on the secure + HA [multi-region private endpoints](../private-link/README.md) scenario to add AAD auth

## References

* [Tutorial: Connect to SQL Database from .NET App Service without secrets using a managed identity](https://docs.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-sql-database)
* [Using AAD auth with SqlClient](https://docs.microsoft.com/en-us/sql/connect/ado-net/sql/azure-active-directory-authentication)

## Bicep Infra Setup

### Linux / Mac

```sh
id=$RANDOM

env1=wus
env2=eus

rg1=adt-rg-$id-$env1
rg2=adt-rg-$id-$env2

loc1=westeurope
loc2=eastus

az group create -g $rg1 -l $loc1
az group create -g $rg2 -l $loc2

az deployment group create -g $rg1 -f main.bicep \
    -p  deploymentId=$id \
        envNamePrimary=$env1 \
        envNameSecondary=$env2 \
        sqlAdminPassword=<something>
az deployment group create -g $rg2 -f main.bicep \
    -p  isSecondary=true \
        primaryDeploymentResourceGroup=$rg1 \
        deploymentId=$id \
        envNamePrimary=$env1 \
        envNameSecondary=$env2 \
        sqlAdminPassword=<something>
```

### Windows

```sh
$id=Get-Random

$env1='wus'
$env2='eus'

$rg1="adt-rg-$id-$env1"
$rg2="adt-rg-$id-$env2"

$loc1='westus'
$loc2='eastus'

az group create -g $rg1 -l $loc1
az group create -g $rg2 -l $loc2

az deployment group create -g $rg1 -f main.bicep -p  deploymentId=$id envNamePrimary=$env1 envNameSecondary=$env2 sqlAdminPassword=<something>
az deployment group create -g $rg2 -f main.bicep -p  isSecondary=true primaryDeploymentResourceGroup=$rg1 deploymentId=$id envNamePrimary=$env1 envNameSecondary=$env2 sqlAdminPassword=<something>
```

### Testing Network Connectivity

From one of the App Service consoles...

```sh
C:\home\site\wwwroot>nameresolver adt-sql-5419.database.windows.net
Server: 168.63.129.16

Non-authoritative answer:
Name: adt-sql-5419-wus.privatelink.database.windows.net
Addresses:
    10.1.1.4
Aliases:
    adt-sql-5419-wus.database.windows.net
    adt-sql-5419-wus.privatelink.database.windows.net

C:\home\site\wwwroot>tcpping adt-sql-5419.database.windows.net:1433
Connected to adt-sql-5419.database.windows.net:1433, time taken: 121ms
Connected to adt-sql-5419.database.windows.net:1433, time taken: 201ms
Connected to adt-sql-5419.database.windows.net:1433, time taken: <1ms
Connected to adt-sql-5419.database.windows.net:1433, time taken: <1ms
Complete: 4/4 successful attempts (100%). Average success time: 80.5ms

C:\home\site\wwwroot>nameresolver adt-sql-5419.secondary.database.windows.net
Server: 168.63.129.16

Non-authoritative answer:
Name: adt-sql-5419-eus.privatelink.database.windows.net
Addresses:
    10.2.1.4
Aliases:
    adt-sql-5419-eus.database.windows.net
    adt-sql-5419-eus.privatelink.database.windows.net

C:\home\site\wwwroot>tcpping adt-sql-5419.secondary.database.windows.net:1433
Connected to adt-sql-5419.secondary.database.windows.net:1433, time taken: 170ms
Connected to adt-sql-5419.secondary.database.windows.net:1433, time taken: 63ms
Connected to adt-sql-5419.secondary.database.windows.net:1433, time taken: 62ms
Connected to adt-sql-5419.secondary.database.windows.net:1433, time taken: 63ms
Complete: 4/4 successful attempts (100%). Average success time: 89.5ms
```

Following forced failover:

> Note: Trace is from a different deployment session. Hence IDs different.

```sh
D:\home\site\wwwroot>nameresolver adt-sql-11053.database.windows.net
Server: 168.63.129.16

Non-authoritative answer:
Name: adt-sql-11053-eus.privatelink.database.windows.net
Addresses:
    10.2.1.4
Aliases:
    adt-sql-11053-eus.database.windows.net
    adt-sql-11053-eus.privatelink.database.windows.net
```

## Deploy the App

### Generate the Database Schema

> Note: You need to open a firewall connection to generate the DB schema.

```sh
cd msdocs-app-service-sqldb-dotnetcore/DotNetCoreSqlDb/

dotnet tool install -g dotnet-ef
dotnet ef migrations add InitialCreate
dotnet ef database update
```

Generates the schema as follows:

```sh
➜  DotNetCoreSqlDb git:(master) ✗ dotnet ef database update
Build started...
Build succeeded.
info: Microsoft.EntityFrameworkCore.Infrastructure[10403]
      Entity Framework Core 6.0.0 initialized 'MyDatabaseContext' using provider 'Microsoft.EntityFrameworkCore.SqlServer:6.0.0' with options: None
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (38ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      SELECT 1
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (33ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      SELECT OBJECT_ID(N'[__EFMigrationsHistory]');
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (23ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      SELECT 1
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (64ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      CREATE TABLE [__EFMigrationsHistory] (
          [MigrationId] nvarchar(150) NOT NULL,
          [ProductVersion] nvarchar(32) NOT NULL,
          CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
      );
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (21ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      SELECT 1
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (23ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      SELECT OBJECT_ID(N'[__EFMigrationsHistory]');
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (34ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      SELECT [MigrationId], [ProductVersion]
      FROM [__EFMigrationsHistory]
      ORDER BY [MigrationId];
info: Microsoft.EntityFrameworkCore.Migrations[20402]
      Applying migration '20220815151401_InitialCreate'.
Applying migration '20220815151401_InitialCreate'.
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (25ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      CREATE TABLE [Todo] (
          [ID] int NOT NULL IDENTITY,
          [Description] nvarchar(max) NULL,
          [CreatedDate] datetime2 NOT NULL,
          CONSTRAINT [PK_Todo] PRIMARY KEY ([ID])
      );
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (26ms) [Parameters=[], CommandType='Text', CommandTimeout='30']
      INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
      VALUES (N'20220815151401_InitialCreate', N'6.0.0');
Done.
```

### Deploy to App Service

```sh
dotnet publish -c Release
```

Right click the publish and select deploy to web app.
