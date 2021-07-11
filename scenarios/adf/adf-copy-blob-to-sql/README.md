# Copy data from Azure Blob Storage to Azure SQL Database

Ref. Azure quickstart templates [data-factory-v2-blob-to-sql-copy](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.datafactory/data-factory-v2-blob-to-sql-copy).

This creates:

- Azure Storage Account and container
- Azure SQL Database
- Azure DataFactory v2 with a pipeline that copies data from a folder in Blob Storage to a table in SQL database

## Setup

### Create resource group and prereqs resources.

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
sqlAdminAccount=sqladmin
sqlAdminAccountPw=<some-password>

az group create -g $rg -l $loc
az deployment group create -g $rg \
    -f azuredeploy.prereqs.json \
    -p azuredeploy.prereqs.parameters.json \
        storageAccountName=adt0sa0$id \
        containerName=adftutorial \
        sqlServerName=adt-sql-$id \
        sqlDBName=adt-db-$id \
        sqlAdministratorLogin=$sqlAdminAccount \
        sqlAdministratorLoginPassword=$sqlAdminAccountPw
```

### Create a source blob

```sh
cat > emp.txt
FirstName,LastName
John,Doe
Jane,Doe
```

Ctrl+D to save.

```sh
az storage blob upload --account-name adt0sa0$id \
    --name input/emp.txt \
    --container-name adftutorial \
    --file emp.txt \
    --auth-mode key
```

### Create database table

Ref. [Prerequisites](https://docs.microsoft.com/en-gb/azure/data-factory/tutorial-copy-data-portal#prerequisites). Note, i did this manually on the database via the Query Editor (Preview) because the M1 isn't supporting [mssql-cli](https://github.com/dbcli/mssql-cli/blob/master/doc/installation/macos.md#macos-installation). Add your client IP to the firewall and then connect using the password.

```sql
CREATE TABLE dbo.emp
(
    ID int IDENTITY(1,1) NOT NULL,
    FirstName varchar(50),
    LastName varchar(50)
)
GO

CREATE CLUSTERED INDEX IX_emp_ID ON dbo.emp (ID);
```
