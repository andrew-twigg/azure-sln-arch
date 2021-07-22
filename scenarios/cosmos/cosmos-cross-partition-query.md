# CosmosDB cross partition queries

Create the database:

```sh
rg=adt-rg-$RANDOM
az group create -g $rg -l westeurope

NAME=adt-co-$RANDOM
az cosmosdb create -g $rg -n $NAME --kind GlobalDocumentDB
az cosmosdb sql database create -g $rg --account-name $NAME -n "Products"
az cosmosdb sql container create \
    -g $rg \
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
