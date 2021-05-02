# CosmosDB cross partition queries

Create the database:

```sh
RG=adt-rg-$RANDOM
az group create -g $RG -l westeurope

NAME=adt-co-$RANDOM
az cosmosdb create -g $RG -n $NAME --kind GlobalDocumentDB
az cosmosdb sql database create -g $RG --account-name $NAME -n "Products"
az cosmosdb sql container create \
    -g $RG \
    --account-name $NAME \
    --database-name "Products" \
    -n "Clothing" \
    --partition-key-path "/productId" \
    --throughput 1000
```

```sh
pip install azure.cosmos
python cosmos-cross-partition-query.py
```

Setting the enable_cross_partition_query to false results in a bad request exception.
