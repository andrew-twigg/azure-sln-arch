# Azure Service Bus Samples

This section includes Service Bus samples including simple quickstarts to demonstrate how to get going, and messaging patterns for advanced scenarios such as highly available disaster tolerant messaging.

## References

* [Azure Service Bus Messaging documentation](https://docs.microsoft.com/en-us/azure/service-bus-messaging/)
* [Azure quickstart templates](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.servicebus)
* [Azure.Messaging.ServiceBus Client library for .NET](https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/servicebus/Azure.Messaging.ServiceBus)
* [Microsoft.ServiceBus Bicep and ARM templates](https://docs.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces?tabs=bicep)
* [Microsoft.ServiceBus.Messaging Geo Replication sample](https://github.com/Azure/azure-service-bus/tree/master/samples/DotNet/Microsoft.ServiceBus.Messaging/GeoReplication)
* [Azure.Identity client library for .NET](https://github.com/Azure/azure-sdk-for-net/blob/main/sdk/identity/Azure.Identity/README.md)
* [Azure SDK Diagnostics](https://github.com/Azure/azure-sdk-for-net/blob/main/sdk/core/Azure.Core/samples/Diagnostics.md#logging)
* [Azure Service Bus message replication and cross-region federation](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-federation-overview)
* [Azure Functions Replication Tasks for BCDR](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-federation-replicator-functions)
* [Azure Logic Apps Replication Tasks for BCDR](https://docs.microsoft.com/en-us/azure/logic-apps/create-replication-tasks-azure-resources?tabs=portal)
* [Azure Samples for messaging replication](https://github.com/Azure-Samples/azure-messaging-replication-dotnet/)
* [Azure Charts for SLAs](https://azurecharts.com/sla?m=adv)

## Samples

* [Azure Service Bus Quickstart](quickstart/README.md)
* [Azure Service Bus Premium Geo-Recovery](service-bus-premium-geo-recovery/README.md)
* [Azure Service Bus Standard Geo-replication (Active & Passive)](service-bus-standard-geo-replication/README.md)
* Coming Soon! Azure Service Bus Standard cross-region federation all-active replication
* Coming Soon! Azure Service Bus Standard cross-region federation active-passive replication
* Coming Soon! Azure Service Bus Standard cross-region federation spillover replication

## Configurations

| Technology           | Configuration                       | Availability                                                                  | Implications                                           | BCDR     |
|----------------------|-------------------------------------|-------------------------------------------------------------------------------|--------------------------------------------------------|----------|
| Service Bus Standard | Single region                       | [99.9](https://azure.microsoft.com/en-gb/support/legal/sla/service-bus/v1_1/) |                                                        | None     |
| Service Bus Standard | Two region, no data replication     | Queue 99.99999, Data 99.9                                                     |                                                        |          |
| Service Bus Standard | Two region, active replication(*)   | Queue 99.99999, Data 99.99999                                                 | Dupe data. Consumer dedupe.                            |          |
| Service Bus Standard | Two region, passive replication(**) | Queue 99.99999, Data 99.99999                                                 | Dupe data. Data loss. Consumer dedupe. Cost optimised. |          |
| Service Bus Premium  | Two region, no data replication     | Not stated. 3x sync data replication in region.                               |                                                        | Built-in |
|                      |                                     |                                                                               |                                                        |          |

* (*) Achievable through cross-region federation all-active replication pattern.
* (**) Achievable through cross-region federation active-passive replication pattern.

## Federation

### Motivation

There's a [deep dive](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-federation-overview) in the docs, but in summary if your solution has the requirement to replicate messages ***across namespace boundaries*** then you need federation. For example, for data resiliency against regional availability events you may have multiple Service Bus namespaces deployed in different regions and require replication of data as well as configuration. If you need ***data*** resiliency across regions then Service Bus Premium won't cover that because it only replicates configuration as part of the Geo-Recovery feature.
