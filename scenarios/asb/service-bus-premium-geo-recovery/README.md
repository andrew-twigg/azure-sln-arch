# Azure Service Bus Premium Geo-Recovery Config and Demo

This scenario deploys Azure Service Bus Premium namespaces across multiple regions and pairs them for Geo-DR failover scenario. The configuration is from [azure quickstart template](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.servicebus/servicebus-create-namespace-geo-recoveryconfiguration). The scenario builds on the quickstart template to add producer consumer apps so that you can fail over the service bus namespaces and check the behaviour.

![geo-recovery config](.assets/service-bus-geo-recovery-config.png)

## Running the sample

### Create the Azure Environment

TODO: Add the queue to the environment.
TODO: Add the shared access policies to the bus for receiver and sender

```sh
// A unique ID for the sample deployment
// Powershell prompt? Use $id=Get-Random.
id=$RANDOM

// Resource group name for both namespaces
// Resource group is primary region, but contains the paired namespace in secondary region
// Powershell prompt? Use $rg="adt-rg-$id".
rg=adt-rg-$id

// Create resource group
az group create -g $rg -l westeurope

// Deploy the environment
az deployment group create -g $rg -f main.bicep -p azuredeploy.parameters.json
```

### Run the Client

TODO: Get the connection string
TODO: Run the client woith the connection string

### Run the Receiver

TODO: Write the receiver
TODO: Run the receiver witht he connection string

## Cleaning up

Break the pairing...

```sh
// See the partner namespace
az servicebus georecovery-alias show -g $rg \
    -a adt-sb-geodr \
    --namespace-name adt-sb-geodr-pri \
    --query "partnerNamespace"

// Break the pair because you cannot delete if paired
az servicebus georecovery-alias break-pair -g $rg \
    --namespace-name adt-sb-geodr-pri \
    --alias adt-sb-geodr

// Check the status (takes a min or so)
az servicebus georecovery-alias show -g $rg \
    -a adt-sb-geodr \
    --namespace-name adt-sb-geodr-pri \
    --query provisioningState \
    -o tsv

Succeeded
```

Delete the resource group.

```sh
// Check the resource group name to make sure its the one you want...
echo $rg

// Delete the resource group
az group delete -g $rg --no-wait -y
```
