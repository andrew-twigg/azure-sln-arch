# Azure Event Hubs Helloworld

## Create Event Hub Namespace

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc
az eventhubs namespace create -g $rg -n adt-eh-$id
```

Deploy the environment.

```sh
userId=$(az ad user list --upn andrew.twigg@hitachivantara.com --query '[].id' -o tsv)
az deployment group create -g $rg \
    -f Infrastructure/main.bicep \
    -p nameSuffix=$id userObjectId=$userId
```

## Run the apps

```sh
eventHubNs=adt-ehns-$id
eventHubName=adt-eh-$id
```

### Producer app

```sh
cd EventHubProducer
dotnet run --event-hub-namespace $eventHubNs --event-hub-name $eventHubName
```

### Consumer app

```sh
cd EventHubConsumer
dotnet run --event-hub-namespace $eventHubNs --event-hub-name $eventHubName
```
