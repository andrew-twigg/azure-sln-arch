# Cosmos DB Quickstart SQL API with .NET Console App

## References

* [Cosmos DB SQL API Console App](https://docs.microsoft.com/en-us/azure/cosmos-db/sql/sql-api-get-started)

## Environment Setup

```sh
id=$RANDOM
rg=adt-rg-$id
az group create -g $rg -l northeurope

cdb=adt-co-$id
az cosmosdb create -g $rg -n $cdb
```

## Create the App

```sh
dotnet new console -n CosmosQuickStart
cd CosmosQuickStart

dotnet add package Microsoft.Extensions.Configuration.UserSecrets
dotnet add package Microsoft.Azure.Cosmos

dotnet new gitignore

documentEndpoint=$(az cosmosdb show -g $rg -n $cdb --query documentEndpoint -o tsv)
primaryMasterKey=$(az cosmosdb keys list -g $rg -n $cdb --query primaryMasterKey -o tsv)

dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:CosmosDocumentEndpoint" $documentEndpoint
dotnet user-secrets set "ConnectionStrings:CosmosPrimaryMasterKey" $primaryMasterKey
```
