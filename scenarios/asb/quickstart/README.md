# Azure Service Bus Quickstart (Bicep)

Reference the Azure Service Bus quickstart [docs](https://docs.microsoft.com/en-gb/azure/service-bus-messaging/service-bus-resource-manager-namespace-queue) and [repo](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.servicebus/servicebus-create-queue).

## Running sample

```sh
az group create -g $rg -l westeurope
az deployment group create -g $rg -f main.bicep -p azuredeploy.parameters.json
```
