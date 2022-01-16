# Azure Service Bus Standard Active Replication

This scenario deploys Azure Service Bus Standard namespaces across multiple regions and implements the [Active replication](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-outages-disasters#active-replication) pattern at the app level as shown in the [Microsoft.ServiceBus.Messaging GeoReplication](https://github.com/Azure/azure-service-bus/tree/master/samples/DotNet/Microsoft.ServiceBus.Messaging/GeoReplication) sample.

## Running the sample

### Create the Azure Environment

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

// Look up the object ID of the account that will run the scenario.
// This is for queue authorization.
userId=$(az ad user list --upn andrew.twigg@hitachivantara.com --query "[].objectId" -o tsv)

// Deploy the environment
az deployment group create -g $rg \
    -f main.bicep \
    -p azuredeploy.parameters.json userObjectId=$userId serviceBusNamespaceNamePrimary=adt-sb-$id-pri serviceBusNamespaceNameSecondary=adt-sb-$id-sec
```

Creates an environment like...

![Environment created](.assets/service-bus-standard-pri-sec.png)

### Run the client

```sh
cd application/MessageSender
dotnet run --sb-primary adt-sb-$id-pri --sb-secondary adt-sb-$id-sec
```
