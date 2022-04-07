# Cosmos DB Table with .Net Core

* [Quickstart](https://docs.microsoft.com/en-us/azure/cosmos-db/table/create-table-dotnet?tabs=azure-cli%2Cvisual-studio)
* [Cosmos DB table storage](https://docs.microsoft.com/en-us/azure/cosmos-db/scripts/cli/table/create)
* [Azure Sample](https://github.com/Azure-Samples/msdocs-azure-data-tables-sdk-dotnet)

## Create Resources

```sh
id=$RANDOM
rg=adt-rg-$id
loc=eastus
acc=adt-cos-$id
table=adt-table-$id

az group create -g $rg -l $loc

az cosmosdb create -g $rg -n $acc \
    --capabilities EnableTable \
    --default-consistency-level Eventual \
    --locations regionName="East US" failoverPriority=0 isZoneRedundant=False \
    --locations regionName="West US" failoverPriority=1 isZoneRedundant=False

az cosmosdb table create -g $rg -a $acc -n $table --throughput 400
```

## Create the App

```sh
dotnet new webapi
dotnet add package Azure.Data.Tables
```

## Add Connection String to Config

```sh
cs=$(az cosmosdb keys list --type connection-strings -g $rg -n $acc --query "connectionStrings[?description=='Primary Table Connection String'].connectionString" -o tsv)
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:CosmosTableApi" $cs
```

## Create the Client

In Program.cs:

```sh
var connectionString = builder.Configuration.GetConnectionString("CosmosTableApi");
builder.Services.AddSingleton<TableClient>(new TableClient(connectionString, "WeatherData"));
```

Add the missing reference to Azure.Data.Tables.


**This demo isn't finished**. Bugs in the code.
