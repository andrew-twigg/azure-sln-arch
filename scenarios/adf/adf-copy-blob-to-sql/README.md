# Copy data from Azure Blob Storage to Azure SQL Database

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
    -p azuredeploy.prereqs.parameters.json storageAccountName adt0sa0$id containerName 
```
