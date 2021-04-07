# Improve the performance of an API by adding a caching policy in Azure API Management

API Management policies are configurable modules that can be added to APIs to change behaviors.
- cache responses
- document transformation and values
- call webhooks for notification or audit purposes
- retry requests after transient failures

APIM Consumption pricing tier has no internal cache, but you could use an external cache, like Redis.

## Policy order

Use the <base /> tag to determine when policies from a higher scope are applied. 

```xml
<policies>
    <inbound>
        <base />
        <find-and-replace from="game" to="board game" />
    </inbound>
</policies>
```
