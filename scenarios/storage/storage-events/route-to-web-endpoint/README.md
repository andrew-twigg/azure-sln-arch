# Quickstart: Route storage events to web endpoint with Azure CLI

## References

* [Quickstart](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-event-quickstart?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json)

## Setup

### Storage Account and Resource Group

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

sa=adt0sa0$id

az storage account create -g $rg -n $sa \
  --location $loc \
  --sku Standard_LRS \
  --kind BlobStorage \
  --access-tier Hot
```

### Create messaging endpoint

This just sets up a prebuilt webapp for listening to events and displaying them.

```sh
plan=adt-sp-$id
sitename=adt-web-$id

az deployment group create -g $rg \
  --template-uri "https://raw.githubusercontent.com/Azure-Samples/azure-event-grid-viewer/master/azuredeploy.json" \
  --parameters siteName=$sitename hostingPlanName=$plan
```

### Event Grid

```sh
az provider register --namespace Microsoft.EventGrid
az provider show --namespace Microsoft.EventGrid --query "registrationState"
```

Subscribe to the storage account register the endpoint for event notifications.

```sh
storageid=$(az storage account show -g $rg -n $sa --query id --output tsv)
endpoint=https://$sitename.azurewebsites.net/api/updates
sub=mystorageevents

az eventgrid event-subscription create \
  --source-resource-id $storageid \
  --name $sub \
  --endpoint $endpoint
```

### Trigger an event

```sh
az storage container create -n testcontainer --account-name $sa

touch testfile.txt
az storage blob upload --file testfile.txt --container-name testcontainer --name testfile.txt --account-name $sa
```
