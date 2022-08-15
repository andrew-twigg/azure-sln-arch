# Azure SQL AAD Auth from App Service with Managed Identity

Key features:
* Demonstrates managed identity as a turn-key solution for securing access to Azure SQL Database from Azure App Service
* Eliminates secrets from the app tier
* Builds on the secure + HA [multi-region private endpoints](../private-link/README.md) scenario to add AAD auth

## References

* [Tutorial: Connect to SQL Database from .NET App Service without secrets using a managed identity](https://docs.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-sql-database)
* [Using AAD auth with SqlClient](https://docs.microsoft.com/en-us/sql/connect/ado-net/sql/azure-active-directory-authentication)

## Bicep Setup

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

## Testing Network Connectivity

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
