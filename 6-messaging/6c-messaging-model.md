# Choose a messaging model in Azure to loosely connect your services

Azure provides several technologies that can be used for reliable communication, including:
- Storage queues
- Event Hubs
- Event Grid
- Service Bus


Loosely coupled architectures require mechanisms for components to communicate. Reliable messaging is often a critical problem.


## References

- Core messaging services architect - [Clemens Vasters](https://vasters.com)
- [On .NET Live Messaging Patterns](https://www.youtube.com/watch?v=ef1DK76rseM)
- Azure docs [Choose between Azure messaging services - Event Grid, Event Hubs, and Service Bus](https://docs.microsoft.com/en-us/azure/event-grid/compare-messaging-services)
- Azure docs [Event Grid](https://docs.microsoft.com/en-us/azure/event-grid/)
- New Azure Service Bus client [Azure.Messaging.ServiceBus](https://github.com/Azure/azure-sdk-for-net/tree/master/sdk/servicebus/Azure.Messaging.ServiceBus)
- [Clemens Vasters GitHub](https://github.com/clemensv)
- [Clemens Vasters GitHub on-dotnet-live-2021-03](https://github.com/clemensv?tab=repositories)
- [Claim-Check Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/claim-check)
- [Key differences between Apache Kafka and Event Hubs](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-for-kafka-ecosystem-overview#key-differences-between-apache-kafka-and-event-hubs)

## Vasters On.NET Live notes

Services don't compete, they are a family for different messaging patters.

![](assets/6c-eventing-messaging-core-services.png)

- Event grids
    - push-push broker
    - broadcast notifications
    - events flow in and then events flow out
    - send data to webhooks, queues, event hubs
    - solving the problem of calling endpoints without having to deal with endpoint downtime
    - creates decoupling as an infrastructure
- Service Bus
    - classic queue broker
    - push in, pull out
- Event hubs
    - push, pull
    - client determines where in retained message log it wants to pull data
        - long tape, move back and forth in time
        - inspect collection of messages
        - do work in batches
    - partitioned for higher flow rates
- Relay
    - connectivity service
    - synchronous invocations
    - composes with the other services


### Service Bus Architectural Patterns

Note on message sizes. At 1h 13m - For Service Bus they are extending the **maximum message size to 100MB** with the large messages feature. Currently 256KB for Standard tier and 1 MB for Premium tier. Other Event Hub and Event Grid, they aren't changing the message size. Use the [Claim-Check pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/claim-check) to stash large messages and then pass a reference through the broker.

Two components:

- Queues
    - log of messages
    - load levelling mechanism
    - transactional behavior
        - atomic ops
        - take a message from a queue, do work, post result another queue, have delete and post in an atomic op
        - approximates classic transaction model we don't have in the cloud of two phase commits
- Topics
    - publish subscriber
    - route to 2K different destinations (commonly not done!)

![](assets/6c-service-bus-patterns.png)


**Competing consumers**

- Queue manages which message is being handed out to consumers
- Message owned exclusively by consumer once assigned

![](assets/6c-service-bus-competing-consumers.png)


**Load Leveling**

- Work jobs can be queued up and processed periodically
- Processor may be offline
- Allows the business process to work at its own pace
- Oportunity to observe queue length and scale the process


### Event Hubs Architectural Patterns

- Super high-scale ingestion broker
- Really useful for when the primary index on data is time axis
    - soon as it becomes something else then better served by a database, so funnel to a DB
- IoT Hub sits on top of Event Hubs
- Separates event streams into partitions (highway lanes)
- Clients are choosing what they want to read
- Make events available for consumptions ASAP, velocity matters


![](assets/6c-event-hubs.png)

![](assets/6c-event-hubs-proc-latency.png)


### Event Grid Architectural Patterns

- Push-push distribution
- Web hook down? What's your app gonna do, sit and wait?
    - Event grid will try reach the endpoint for 24hrs
    - back off if there's errors
    - deadletter if it can't deliver


![](assets/6c-event-grid.png)


### Relay Architectural Patterns

- Exposing services from behind firewalls
- Reach anything and everything
- Reverse web socket across firewalls

![](assets/6c-relay.png)


### Big picture

- Picture is bigger than the broker
    - sourcing events
        - events come from many different sources
        - 300+ adapters on logic apps
        - edge systems for IoT events
    - transformation and routing
        - Azure Functions
        - Event Grid / Service Bus / Event Hubs
- Open standards story, no future in proprietary protocols
    - AMQP
    - MQTT
    - HTTP
    - interop story with other brokers
- Services on the platform are part of an ecosystem
    - brokers on the left, services on the right
    - Azure already has loads of the services on the platform

![](assets/6c-event-journeys.png)


## Messages or events?

Question: *Does the sender expect the communication to be processed in a particular way be the destination component?* If yes then choose a message, otherwise it may be events.

Messages
- contains raw data, not just a reference
- sending component expects the message content to be processed in a certain way by destination component

Events
- light weight notifications, doesn't contain data
- multiple receivers or none at all
- publisher has no expectation about the action a receiving component take


## Choosing a message-based delivery with queues

- Azure Queue Storage
    - store large numbers of messages, limited only by storage account capacity
    - accessed via REST API from anywhere
- Azure Service Bus
    - enterprise message broker
    - built for enterprise scenarios
        - multiple comms protocols
        - different data contracts
        - high security requirements
        - cloud + on-prem services
    - built on dedicated infra
- Topics
    - support multiple subscribers


### Benefits of queues

- increased reliability
- delivery guarantees
    - **At-Least-Once** delivery
        - delivery to at least one of the components that retrieve messages from the queue
        - possible same message may be delivered more than once, ex. in long processing time / timeout scenarios
    - **At-Most-Once** delivery
        - each message is not guaranteed for delivery
        - small chance message won't arrive
        - no change message will be delivered twice
        - *automatic duplicate detection*
    - **First-In-First-Out**
        - if app requires processing of messages in precise order then look for FIFO guarantee


### Transactional support

Message transactions succeed or fail as a single unit.


### Which service should you choose?

- Service Bus topics
    - when you have multiple receivers handling a message
- Service Bus queues
    - need At-Most-Once
    - need FIFO guarantee
    - need transactions
    - receive without polling
    - RBAC on queues
    - need larger messages
    - max queue size is less than the max limit (80 GB)
    - publishing / consuming batches of messagees
- Queue storage
    - simpler choice without without above features
    - need an audit trail of all messages
    - large queue sizes > 80GB
    - want to track progress for processing a message inside a queue


## Choose Azure Event Grid

- supports most Azure services as a publisher or subscriber + third party services
- dynamically scalable, low-cost, messaging system, allowing publishers to notify subscribers about change
- concepts connecting source and subscriber
    - **Events**: what happened
    - **Event sources**: where event took place
    - **Topics**: endpoint where publishers send events
    - **Event subscriptions**: endpoint to route events
    - **Event handlers**: app / service reacting to events


![](assets/6c-event-grid2.png)


### When to use

- **Simplicity**: simple to connect sources to subscribers
- **Advanced filtering**: subscriptions have close control over events they receive
- **Fan-out**: subscribe to an unlimited number of endpoint to the same events and topics
- **Reliability**: retries upto 24h per sub
- **Pay-per-event**: micro billing at event level


### Event topics

- categorise events into groups
- also represented by a public endpoint where the event source sends events *to*


### System topics

- built in topics provided by Azure Services
- as long as you have access to the resource, you can subscribe to events


### Custom topics

- application and third party topics


## Choose Azure Event Hubs

Provides a distributed stream processing platform with low latency and seamless integration with data and analytics services, inside and outside of Azure, for big-data pipelines.

- timely insights from sources
- big data streaming platform and event ingestion service
- capable of receiving and processing millions of events per second
- fully managed PaaS
- front door for an event pipeline (***event ingestor***)
    - component or service that sits between an event publisher and consumer
    - decouple event stream from consumption of those events
- time retention buffer
- capture feature
    - real-time and batch processing
    - build for todays batch processing on a platform that supports tomorrows real time processing
- easiest way to load data into Azure
    - volume
    - varienty
    - velocity
- partitions (buffers)
    - Event Hubs divides comms into partitions
    - buffers into which the comms are saved
    - events are not completely ephemeral
    - subscribers can use the buffer to catch up


### When to use

- need to support authenticating large number of publisher
- need to save a stream of events to Data Lake or Blob storage
- need aggregation or analytics on your event stream
- need reliable messaging or resiliency
