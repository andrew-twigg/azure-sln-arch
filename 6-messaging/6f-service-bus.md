# Implement message-based communication workflows with Azure Service Bus


## Choosing a messaging platform

There are two Azure features that include message queues: Service Bus and Azure Storage accounts. As a general guide, storage queues are simpler to use but are less sophisticated and flexible than Service Bus queues.

Key advantages of Service Bus queues include:
- Supports larger messages sizes of 256 KB (standard tier) or 1MB (premium tier) per message versus 64 KB (note, premium is going to 100 MB soon)
- Supports both at-most-once and at-least-once delivery - choose between a very small chance that a message is lost or a very small chance it is handled twice
- Guarantees first-in-first-out (FIFO) order - messages are handled in the same order they are added (although FIFO is the normal operation of a queue, it is not guaranteed for every message)
- Can group multiple messages into a transaction - if one message in the transaction fails to be delivered, all messages in the transaction will not be delivered
- Supports role-based security
- Does not require destination components to continuously poll the queue


Advantages of storage queues:
- Supports unlimited queue size (versus 80-GB limit for Service Bus queues)
- Maintains a log of all messages


### Choosing a communications technology

1. Is the communication an event? If so, consider using Event Grid or Event Hubs.
2. Should a single message be delivered to more than one destination? If so, use a Service Bus topic. Otherwise a queue.


### Choose Service Bus queues if:

- You need an at-most-once delivery guarantee
- You need a FIFO guarantee
- You need to group messages into transactions
- You want to receive messages without polling the queue
- You need to provide role-based access to the queues
- You need to handle messages larger than 64 KB but smaller than 256 KB
- Your queue size will not grow larger than 80 GB
- You would like to be able to publish and consume batches of messages


### Choose queue storage if:

- You need a simple queue with no particular additional requirements
- You need an audit trail of all messages that pass through the queue
- You expect the queue to exceed 80 GB in size
- You want to track progress for processing a message inside of the queue

