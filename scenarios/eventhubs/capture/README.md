# Azure Event Hubs Capture

## References

* [Event Hubs Capture](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-overview)

## Create Event Hub Namespace

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc
```

Deploy the environment. Run under the account for the local user logged in to Azure.

This generates:

* Event Hub namespace
* Event Hub
* Storage account and container
* Event Hub Capture configuration to capture to the storage account container

```sh
userUpn=$(az account show --query user.name -o tsv)
userId=$(az ad user list --upn $userUpn --query '[].id' -o tsv)
az deployment group create -g $rg \
    -f Infrastructure/main.bicep \
    -p nameSuffix=$id userObjectId=$userId
```

## Run the producer app

This generates event data to capture to the storage account container.

```sh
eventHubNs=adt-ehns-$id
eventHubName=adt-eh-$id

cd EventHubProducer
dotnet run --event-hub-namespace $eventHubNs --event-hub-name $eventHubName
```
