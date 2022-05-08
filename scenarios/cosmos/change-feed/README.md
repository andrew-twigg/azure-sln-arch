# Cosmos DB Change Feed

This is the scenario for [Cosmos DB change feed with Azure Functions](https://azurecosmosdb.github.io/labs/dotnet/labs/08-change_feed_with_azure_functions.html). The [Lab Setup](#setup-the-lab) section implements the [Lab Setup](https://azurecosmosdb.github.io/labs/dotnet/labs/00-account_setup.html) steps.

The scenario creates a data generator to simulate documents creating in a database, and clients which use the Cosmos DB change feed to receive documents. The Console client uses the SDK to register for change and syncs to another collection. The Function client demonstrates the materialised view pattern.

There is also an example of how to [use Azure Cosmos DB Change Feed to Write Data to EventHub using Azure Functions](https://azurecosmosdb.github.io/labs/dotnet/labs/08-change_feed_with_azure_functions.html#use-azure-cosmos-db-change-feed-to-write-data-to-eventhub-using-azure-functions).

## References

* [Change Feed Overview](https://docs.microsoft.com/en-us/azure/cosmos-db/change-feed)
* [Change Feed Design Patterns](https://docs.microsoft.com/en-us/azure/cosmos-db/sql/change-feed-design-patterns)
* [Change Feed Examples](https://docs.microsoft.com/en-us/azure/cosmos-db/sql/sql-api-dotnet-v3sdk-samples#change-feed-examples)
* [Change Feed Labs, Azure Functions](https://azurecosmosdb.github.io/labs/dotnet/labs/08-change_feed_with_azure_functions.html)

## Setup the lab

This creates the components needed to show the scenario:

* Cosmos DB Account
* Data Factory
* Event Hubs Namespace
* Storage Account
* Stream Analytics job

Comes from the [lab setup](https://github.com/AzureCosmosDB/labs/blob/master/dotnet/setup/labSetup.ps1) script.

### Resource Group

```sh
id=$RANDOM
loc=eastus
rg=adt-rg-$id

az group create -g $rg -l $loc
```

### Cosmos DB

```sh
cdb=adt-db-$id
az cosmosdb create -g $rg -n $cdb

az cosmosdb sql database create -g $rg \
    -a $cdb \
    -n FinancialDatabase
az cosmosdb sql container create -g $rg \
    -a $cdb \
    -d FinancialDatabase \
    -n PeopleCollection \
    -p "/accountHolder/LastName"
az cosmosdb sql container create -g $rg \
    -a $cdb \
    -d FinancialDatabase \
    -n TransactionCollection \
    -p "/costCenter" \
    --throughput 10000

az cosmosdb sql database create -g $rg \
    -a $cdb \
    -n NutritionDatabase
az cosmosdb sql container create -g $rg \
    -a $cdb \
    -d NutritionDatabase \
    -n FoodCollection \
    -p "/foodGroup" \
    --throughput 11000

az cosmosdb sql database create -g $rg \
    -a $cdb \
    -n StoreDatabase
az cosmosdb sql container create -g $rg \
    -a $cdb \
    -d StoreDatabase \
    -n CartContainer \
    -p "/Item"
az cosmosdb sql container create -g $rg \
    -a $cdb \
    -d StoreDatabase \
    -n CartContainerByState \
    -p "/BuyerState"
az cosmosdb sql container create -g $rg \
    -a $cdb \
    -d StoreDatabase \
    -n StateSales \
    -p "/State"
```

### Azure Storage

```sh
sa=adt0sa0$id
az storage account create -g $rg -l $loc -n $sa
az storage container create -g $rg -n data \
    --account-name $sa \
    --auth-mode key

wget https://raw.githubusercontent.com/AzureCosmosDB/labs/master/dotnet/setup/NutritionData.json

# Had to do manually because of timeout
az storage blob upload --account-name $sa \
    --name NutritionData.json \
    --container-name nutritiondata \
    --file NutritionData.json \
    --auth-mode key

sacs=$(az storage account show-connection-string -g $rg -n $sa --key primary --query "connectionString" -o tsv)

```

### Event Hub

```sh
eh=adt-eh-$id
az eventhubs namespace create -g $rg -n $eh
az eventhubs eventhub create -g $rg \
    -n CartStreamProcessor \
    --namespace-name $eh \
    --message-retention 1
```

### Stream Processor

```sh
az stream-analytics job create -g $rg \
    -n CartStreamProcessor \
    -l $loc \
    --out-of-order-policy "adjust" \
    --order-max-delay 10 \
    --compatibility-level "1.2" \
    --transformation name="Transformation" \
        streaming-units=1 \
        query="/*TOP 5*/
WITH Counter AS
(
    SELECT Item, Price, Action, COUNT(*) AS countEvents
    FROM cartinput
    WHERE Action = 'Purchased'
    GROUP BY Item, Price, Action, TumblingWindow(second,300)
),
top5 AS
(
    SELECT DISTINCT CollectTop(5)
    OVER (ORDER BY countEvents) AS topEvent
    FROM Counter
    GROUP BY TumblingWindow(second,300)
),
arrayselect AS
(
    SELECT arrayElement.ArrayValue
    FROM top5
    CROSS APPLY GetArrayElements(top5.topevent)
    AS arrayElement
)
SELECT arrayvalue.value.item,
       arrayvalue.value.price,
       arrayvalue.value.countEvents
INTO top5Output
FROM arrayselect

/*REVENUE*/
SELECT System.TimeStamp AS Time,
       SUM(Price)
INTO incomingRevenueOutput
FROM cartinput
WHERE Action = 'Purchased'
GROUP BY TumblingWindow(minute, 5)

/*UNIQUE VISITORS*/
SELECT System.TimeStamp AS Time,
       COUNT(DISTINCT CartID) as uniqueVisitors
INTO uniqueVisitorCountOutput
FROM cartinput
GROUP BY TumblingWindow(second, 30)

/*AVERAGE PRICE*/
SELECT System.TimeStamp
AS Time, Action, AVG(Price)
INTO averagePriceOutput
FROM cartinput
GROUP BY Action, TumblingWindow(second,30) "
```

### Azure Data Factory

Add-DataSet $resourceGroupName "importNutritionData$randomNum" $location $accountName "NutritionDatabase" "FoodCollection"

```sh
cdbUrl="https://$cdb.documents.azure.com:443/"

# Blob location should be replaced by new hosted container-read SAS
storageAccountLocation="https://$sa.blob.core.windows.net"
storageAccountSas="?sv=2018-03-28&ss=bfqt&srt=sco&sp=rlp&se=2022-01-01T04:55:28Z&st=2019-08-05T20:02:28Z&spr=https&sig=%2FVbismlTQ7INplqo6WfU8o266le72o2bFdZt1Y51PZo%3D"
sourceBlobFolder="nutritiondata"
sourceBlobFile="NutritionData.json"
pipelineName="ImportLabNutritionData"

cosmosKey=$(az cosmosdb keys list -g $rg -n $cdb --query primaryMasterKey -o tsv)

adf=adt-df-$id
az datafactory create -g $rg --factory-name $adf

echo "{ \"type\":\"AzureStorage\", \"typeProperties\": { \"connectionString\": { \"type\": \"SecureString\", \"value\": \"$sacs\" } } }" >> AzureStorageLinkedService.json

echo "{ \"type\":\"CosmosDb\", \"typeProperties\": { \"connectionString\": { \"type\":\"SecureString\", \"value\":\"AccountEndpoint=$cdbUrl;AccountKey=$cosmosKey;Database=NutritionDatabase\" } } }" >> CosmosDbSQLAPILinkedService.json

az datafactory linked-service create -g $rg \
    --factory-name $adf \
    --linked-service-name AzureStorageLinkedService \
    --properties @AzureStorageLinkedService.json

az datafactory linked-service create -g $rg \
    --factory-name $adf \
    --linked-service-name CosmosLinkedService \
    --properties @CosmosDbSQLAPILinkedService.json

echo "{ \"type\":\"AzureBlob\", \"typeProperties\": { \"format\": { \"type\": \"JsonFormat\", \"filePattern\": \"arrayOfObjects\" }, \"fileName\": \"$sourceBlobFile\", \"folderPath\": \"$sourceBlobFolder\" }, \"linkedServiceName\": { \"referenceName\": \"AzureStorageLinkedService\", \"type\": \"LinkedServiceReference\"}, \"parameters\": {} }" >> BlobDataset.json

echo "{ \"type\":\"DocumentDbCollection\", \"linkedServiceName\": {\"referenceName\": \"CosmosLinkedService\", \"type\": \"LinkedServiceReference\"}, \"typeProperties\": {\"collectionName\": \"FoodCollection\"} }" >> CosmosDataset.json

az datafactory dataset create -g $rg \
    --factory-name $adf \
    --dataset-name BlobDataset \
    --properties @BlobDataset.json

az datafactory dataset create -g $rg \
    --factory-name $adf \
    --dataset-name CosmosDataset \
    --properties @CosmosDataset.json

az datafactory pipeline create -g $rg \
    --factory-name $adf \
    --name $pipelineName \
    --pipeline @CopyPipeline.json
```

Create a pipeline run:

```sh
az datafactory pipeline create-run -g $rg \
    --factory-name $adf \
    --pipeline-name $pipelineName
```

## Exercise 1: Build .NET Console App to Generate Data

Comes from the [lab](https://github.com/AzureCosmosDB/labs/tree/master/dotnet/solutions/08-change_feed_with_azure_Functions/DataGenerator).

Simulates data flowing into a store, in the form of actions on an e-commerce website. Adds docs to the Cosmos DB CartContainer.

```sh
dotnet new console -n DataGenerator
cd DataGenerator

dotnet add package Microsoft.Extensions.Configuration.UserSecrets
dotnet add package Microsoft.Azure.Cosmos
dotnet add package Bogus

cs=$(az cosmosdb keys list --type connection-strings -g $rg -n $cdb --query "connectionStrings[?description=='Primary SQL Connection String'].connectionString" -o tsv)
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:CosmosSqlApi" $cs
```
