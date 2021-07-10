# Copy data from Azure Blob Storage to Azure SQL Database

Ref. [azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.datafactory/data-factory-v2-blob-to-sql-copy).

This template creates:

- Azure Storage Account and container
- Azure SQL Database
- Azure DataFactory v2 with a pipeline that copies data from a folder in Blob Storage to a table in SQL database


```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

az deployment group create -g $rg \
    -f azuredeploy.prereqs.json \
    -p azuredeploy.prereqs.parameters.json \
        storageAccountName=adt0sa0$id \
        containerName=mysourcecontainer \
        sqlServerName=adt-sql-$id \
        sqlDBName=adt-db-$id \
        sqlAdministratorLogin=sqladmin \
        sqlAdministratorLoginPassword=Pas5w0rd123456


```

How to then run SQL to setup the tables? Ref. [odetocode](https://odetocode.com/blogs/scott/archive/2018/01/23/interacting-with-azure-sql-using-all-command-line-tools.aspx), use [mssql-cli](https://github.com/dbcli/mssql-cli/blob/master/doc/installation/macos.md#macos-installation).
