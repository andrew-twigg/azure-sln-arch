# Azure Event Hubs Helloworld

## Create Event Hub Namespace

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

az eventhubs namespace create -g $rg -n adt-eh-$id
```

Get the connection string.

```sh
cs=$(az eventhubs namespace authorization-rule keys list -g $rg \
    --name RootManageSharedAccessKey \
    --namespace-name adt-eh-$id \
    --query "primaryConnectionString" -o tsv)
```

Create event hub.

```sh
hubname=adt-hub-$id
az eventhubs eventhub create -g $rg -n $hubname --namespace-name adt-eh-$id
```

## Create the Producer App

Create a console app.

```sh
dotnet new console -n EventHubProducer
cd EventHubProducer

dotnet add package Azure.Messaging.EventHubs
dotnet add package Microsoft.Extensions.Configuration.UserSecrets
dotnet build
```

Initialise the secrets and add the connection string.

```sh
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:EventHub" $cs
```

Add the Event Hub name to tbe appsettings.json.

## Create the Consumer App

Create a console app.

```sh
dotnet new console -n EventHubConsumer
cd EventHubConsumer

dotnet add package Azure.Messaging.EventHubs
dotnet add package Microsoft.Extensions.Configuration.UserSecrets
dotnet build
```

Initialise the secrets and add the connection string.

```sh
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:EventHub" $cs
```

Add the Event Hub name to the the appsettings.json.
