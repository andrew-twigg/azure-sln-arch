# Copy data from Azure Blob Storage to Azure SQL Database

Ref. Azure quickstart templates [data-factory-v2-provision-ssis-runtime](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.datafactory/data-factory-v2-provision-ssis-runtime).
Ref. ADF tutorials [Run SSIS Packages in Azure](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-deploy-ssis-packages-azure#prerequisites)
This creates:

- Azure SQL Database
- Azure DataFactory v2
- Provisions an Azure SSIS integration runtime 

## Setup

### Create resource group and prereqs resources.

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
sqlAdminAccount=sqladmin
sqlAdminAccountPw=<some-password>
vnet=adt-vnet-$id
snet=adt-snet-$id

az group create -g $rg -l $loc
az deployment group create -g $rg \
    -f azuredeploy.prereqs.json \
    -p azuredeploy.prereqs.parameters.json \
        sqlServerName=adt-sql-$id \
        sqlDBName=adt-db-$id \
        sqlAdministratorLogin=$sqlAdminAccount \
        sqlAdministratorLoginPassword=$sqlAdminAccountPw \
        virtualNetworkName=$vnet \
        subnetName=$snet
```

### Create the Azure Data Factory

```sh
az provider register --namespace Microsoft.Batch                            
az provider show -n Microsoft.Batch --query "registrationState" -o tsv
Registered

az deployment group create -g $rg \
    -f azuredeploy.json \
    -p azuredeploy.parameters.json \
        factoryName=adt-adf-$id \
        virtualNetworkName=$vnet \
        subNetName=$snet \
        azureSqlServerName=adt-sql-$id \
        databaseAdminUsername=$sqlAdminAccount \
        databaseAdminPassword=$sqlAdminAccountPw
```
