# Cosmos DB Gremlin with .Net Core

Ref. https://docs.microsoft.com/en-us/azure/cosmos-db/create-graph-dotnet
Ref. https://docs.microsoft.com/en-us/azure/cosmos-db/scripts/cli/gremlin/create


```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
acc=adt-cos-$id
db=adt-db-$id
graph=sample-graph

az group create -g $rg -l $loc

az cosmosdb create -g $rg -n $acc \
    --capabilities EnableGremlin \
    --default-consistency-level Eventual \
    --locations regionName='West Europe' failoverPriority=0 isZoneRedundant=False \
    --locations regionName='North Europe' failoverPriority=1 isZoneRedundant=False

az cosmosdb gremlin database create -g $rg -a $acc -n $db

printf ' 
{
    "indexingMode": "consistent", 
    "includedPaths": [
        {"path": "/*"}
    ],
    "excludedPaths": [
        { "path": "/headquarters/employees/?"}
    ],
    "spatialIndexes": [
        {"path": "/*", "types": ["Point"]}
    ],
    "compositeIndexes":[
        [
            { "path":"/name", "order":"ascending" },
            { "path":"/age", "order":"descending" }
        ]
    ]
}' > "cosmos-gremlic-dotnet-idxpolicy-$id.json"

az cosmosdb gremlin graph create -g $rg -a $acc -d $db -n $graph -p '/pk' --throughput 1000
```

DotNet app...


```sh
git clone https://github.com/Azure-Samples/azure-cosmos-db-graph-gremlindotnet-getting-started.git

cd azure-cosmos-db-gremlindotnet-getting-started

dotnet restore
```

I didn't finish it, answered the question i needed to.
