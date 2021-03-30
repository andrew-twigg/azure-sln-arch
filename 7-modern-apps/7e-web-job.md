# Run a background task in an App Service Web App with WebJobs


## WebJobs vs Azure Functions

- Functions can run on a schedule or continuously so can be used instead of WebJobs for background tasks
- Functions is a logical successor of WebJobs for most workloads
- Functions is built on the WebJobs SDK
- For most automated tasks, build Functions because they are more flexible (autoscale scale / development workflow)
- WebJobs can be used to deploy code alongside the code for the website its associated with
- WebJobs give greater control over the JobHost object


## Create a WebJob


```sh
# create a storage account
STORAGE_ACCOUNT_NAME=mslearnwebjobs$RANDOM

az group create --name mslearn-webjobs --location <location>
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group mslearn-webjobs

STORAGE_ACCOUNT_CONNSTR=$(az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME --query connectionString --output tsv)

echo "Created storage account $STORAGE_ACCOUNT_NAME"


# configure the web app
WEB_APP_ID=$(az webapp list --resource-group mslearn-webjobs --query [0].id --output tsv)
az webapp config set --id $WEB_APP_ID --always-on true
az webapp config connection-string set --id $WEB_APP_ID --connection-string-type Custom --settings StorageAccount=$STORAGE_ACCOUNT_CONNSTR
```

Write the code...

```csharp
using System.Configuration;
using System.Threading;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Queue;


var queue = CloudStorageAccount.Parse(ConfigurationManager.ConnectionStrings["StorageAccount"].ConnectionString)
    .CreateCloudQueueClient()
    .GetQueueReference("stockchecks");

queue.CreateIfNotExists();

while (true)
{
    var timestamp = DateTimeOffset.UtcNow.ToString("s");

    var message = new CloudQueueMessage($"Stock check at {timestamp} completed");
    queue.AddMessage(message);

    Thread.Sleep(TimeSpan.FromSeconds(30));
}
```


## WebJobs SDK

Using .NET framework to build WebJobs gives you the SDK which will make several programming tasks easier and quicker.

- WebJobs SDK
    - simplify many programming takss common to WebJobs
    - not required, but helpful
    - features for working with storage, service busm scheduling tasks, error handling
- Host
    - JobHost object
    - listens to trigger events and call functions
