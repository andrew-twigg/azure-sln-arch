# Azure Service Bus Premium Geo-Recovery Config and Demo

This scenario deploys Azure Service Bus Premium namespaces across multiple regions and pairs them for Geo-DR failover scenario. The configuration is from [azure quickstart template](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.servicebus/servicebus-create-namespace-geo-recoveryconfiguration). The scenario builds on the quickstart template to add producer consumer apps so that you can fail over the service bus namespaces and check the behaviour.

![geo-recovery config](.assets/service-bus-geo-recovery-config.png)

## Running the sample

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