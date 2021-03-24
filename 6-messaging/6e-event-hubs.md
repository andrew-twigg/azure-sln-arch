# Enable reliable messaging for Big Data applications using Azure Event Hubs

Connect sending and receiving apps with Event Hubs so they can handle extremely high loads without losing data.

## Overview

- Cloud-based event processing service
- receive and process millions of events per second
- front door for an event pipeline
- stores events until they can be consumed
- introduces a load levelling capability

![](assets/6e-event-hub-overview.png)


### Events

- small packet of information (datagram) that contains a notification
- publish individually or batched
- publications cannot exceed 1 MB


### Publishers and subscribers

- any thing that can send events using either HTTPS or AMQP 1.0
- AMQP has better performance, but with higher initial session overhead due to persistent bidirectional socket and TLS setup
- HTTPS is better for more intermitten publishing
    - requires additional overhead for each request
    - no session initialisation overhead
- Kafka-based clients 1.0 or newer can act as publishers
- subscribers, apps that use one of two supported methods to receive
    - EventHubReceiver - Simple, limited management options
    - EventProcessorHost - efficient


### Consumer groups

- specific view of an Event Hub data stream
- multiple subscriber apps can process an event stream independently and without affecting other apps
- not a requirement


## Creating

```sh
az configure --defaults group=$RG location=westus2
az eventhubs namespace create --name $NS_NAME

# get the connection string
az eventhubs namespace authorization-rule keys list \
    --name RootManageSharedAccessKey \
    --namespace-name $NS_NAME

# create the hub
az eventhubs eventhub create \
    --name $HUB_NAME \
    --namespace-name $NS_NAME
az eventhubs eventhub show \
    --namespace-name $NS_NAME \
    --name $HUB_NAME
```


