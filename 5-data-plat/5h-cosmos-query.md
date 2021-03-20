# Insert and query data in your Azure Cosmos DB database

Create an Azure Cosmos DB account + database:

```bash
export NAME=cosmos$RANDOM

az cosmosdb create \
    --name $NAME \
    --kind GlobalDocumentDB \
    --resource-group $RG

az cosmosdb sql database create \
    --account-name $NAME \
    --name "Products" \
    --resource-group $RG

az cosmosdb sql container create \
    --account-name $NAME \
    --database-name "Products" \
    --name "Clothing" \
    --partition-key-path "/productId" \
    --throughput 1000 \
    --resource-group $RG
```


## Stored procedures and User Defined Functions

Stored procedures are the only way to ensure ACID (Atomicity, Consistency, Isolation, Durability) transactions because they are run on the server.

UDFs are also stored on the server and are used during queries to perform computational logic on values or documents within the query.


### Stored procedures

- perform complex transactions on documents and properties
- written in JavaScript and are stored in a container on Azure Cosmos DB
- close to data, on the DB engine, can improve performance
- only way to perform atomic transactions, client SDKs don't support transactions
- performing batch ops in stored procs is also recommended because don't need to create separate transactions


```sh
function helloWorld() {
    var context = getContext();
    var response = context.getResponse();

    response.setBody("Hello, World");
}
```


### User-defined function basics

- extend Cosmos DB SQL query language grammar and implement custom business logic
- can be called only from inside queries
- don't have access to the context object (unlike sprocs) so can't read/write docs


