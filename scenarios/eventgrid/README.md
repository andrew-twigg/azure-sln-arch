# Quickstart: Route custom events to web endpoint with Azure CLI and Event Grid

## References

* [Quickstart](https://docs.microsoft.com/en-us/azure/event-grid/custom-event-quickstart)

## Setup

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
az group create -g $rg -l $loc
```

Register the Event Grid resource provider.

```sh
az provider register --namespace Microsoft.EventGrid
az provider show --namespace Microsoft.EventGrid --query "registrationState"
```

Create a topic to provide a user-defined endpoint to post events to.

```sh
topicname=adt-eg-topic-$id
az eventgrid topic create -g $rg -l $loc -n $topicname
```

Deploy a pre-built web app that displays event info. This represents the event processor.

```sh
sitename=adt-web-$id

az deployment group create -g $rg \
  --template-uri "https://raw.githubusercontent.com/Azure-Samples/azure-event-grid-viewer/master/azuredeploy.json" \
  --parameters siteName=$sitename hostingPlanName=adt-sp-$id
```

## Subscribe to the custom topic

```sh
endpoint=https://$sitename.azurewebsites.net/api/updates
sub=$(az account show --query "id" -o tsv)
az eventgrid event-subscription create \
  --source-resource-id "/subscriptions/$sub/resourceGroups/$rg/providers/Microsoft.EventGrid/topics/$topicname" \
  --name demoViewerSub \
  --endpoint $endpoint
```

You get the subscription event...

```json
[{
  "id": "da800ee7-93f8-48f4-87db-ee79f0338e17",
  "topic": "/subscriptions/b70490c4-40b2-4066-afc9-05b797168001/resourceGroups/adt-rg-15821/providers/microsoft.eventgrid/topics/adt-eg-topic-15821",
  "subject": "",
  "data": {
    "validationCode": "FDC9B5C6-4E74-4CEF-945E-46772F6B95F2",
    "validationUrl": "https://rp-westeurope.eventgrid.azure.net:553/eventsubscriptions/demoviewersub/validate?id={GUID}=2022-06-26T20:28:02.2043885Z&apiVersion=2020-10-15-preview&token={TOKEN}"
  },
  "eventType": "Microsoft.EventGrid.SubscriptionValidationEvent",
  "eventTime": "2022-06-26T20:28:02.2043885Z",
  "metadataVersion": "1",
  "dataVersion": "2"
}]
```

The validation code is part of the [handshake](https://docs.microsoft.com/en-us/azure/event-grid/webhook-event-delivery#endpoint-validation-with-event-grid-events) that takes place between Event Grid and the endpoint to prove ownership of the webhook endpoint before Event Grid starts sending events to the endpoint.

## Send an event to the custom topic

```sh
endpoint=$(az eventgrid topic show -g $rg -n $topicname --query "endpoint" --output tsv)
key=$(az eventgrid topic key list -g $rg -n $topicname --query "key1" --output tsv)
```

Define an event. This is typically a step for an event producer app.

```json
event='[ {"id": "'"$RANDOM"'", "eventType": "recordInserted", "subject": "myapp/vehicles/motorcycles", "eventTime": "'`date +%Y-%m-%dT%H:%M:%S%z`'", "data":{ "make": "Ducati", "model": "Monster"},"dataVersion": "1.0"} ]'
```

Send the event...

```sh
curl -X POST -H "aeg-sas-key: $key" -d "$event" $endpoint
```
