# Service Bus Topic Filters

Runs through the Service Bus [Topic Filters](https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/servicebus/Azure.Messaging.ServiceBus/samples/TopicFilters) sample.

## Setup

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

// Look up the object ID of the account that will run the scenario.
// This is for queue authorization.
userId=$(az ad user list --upn andrew.twigg@hitachivantara.com --query '[].id' -o tsv)

asb=adt-sb-$id
az deployment group create -g $rg -f main.bicep -p serviceBusNamespaceName=$asb userObjectId=$userId
```

## Run the application

```sh
dotnet run --service-bus-namespace $asb
```
