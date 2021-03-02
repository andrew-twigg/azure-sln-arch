# Traffic Manager

Provides DNS load balancing. Distributes traffic to services across Azure regions globally. Helps provide HA, resilience, and responsiveness.

## Learning Objectives

- Distribute network traffic
- Failover to secondary regions
- Redirect to nearest endpoint

## How it works

DNS based solution. Traffic Manager uses DNS to direct clients to a specific endpoint based on the rules of the traffic routing method thats used. Clients connect directly to the selected endpoint. Its not a proxy or a gateway, and doesn't see the traffic that passes between the clients and the service. Just gives the clients the IP addresses of where they need to go.

![](assets/1e-worldwide.svg)


## Endpoints

The destination location that is returned to the client. Configure each app deployment as an endpoint in Traffic Manager. Traffic Manager receives a DNS request and chooses an available endpoint to return in the DNS response.  
Three types of endpoint supported:

1. <b>Azure endpoints</b> used for services hosted in Azure (App Service, Public IP)
2. <b>External endpoints</b> used for IPv4/IPv6 addresses, FQDNs, or services hosted outside of Azure
3. <b>Nested endpoints</b> used to combine Traffic Manager profiles to create more flexible traffic-routing schemes


## Routing methods

Traffic Manager supports different methods for routing traffic to multiple endpoints. Applies routing method to each DNS query it receives and determines which endpoint is returned in the response.

Six routing methods.


### Weighted routing

- Distribute traffic across endpoints either evenly or based on different weights.
- Weight is 1 to 1000
- Randomly chooses an available endpoint
- Probability of choosing an endpoint is based on weights assigned to endpoints

![](assets/1e-weighted.png)


### Performance routing

- For use across different geographic locations
- Uses an internet latency table which actively tracks network latencies to endpoints around the globe
- Best performing endpoint is returned based on location request

![](assets/1e-performance.png)


### Geographic routing

- Routes to endpoints based on where the DNS query originates
- Enables geo-fencing content to specific user regions

![](assets/1e-geographic.png)


### Multivalue routing

- Used to get multiple healthy endpoints in a single DNS query response
- Client-side retries with other endpoints if an endpoint is unresponsive
- Pattern increases availability of a service and reduces latency associated with a new DNS query to obtain a health endpoint


### Subnet routing

- Maps a set of user IP ranges to specific endpoints within a Traffic Manager profile
- Returns the endpoint that is mapped to the requests source IP address


### Priority routing

- Traffic Manager contains a prioritized list of service endpoints.
- Default is to send all traffic to the primary (highest-priority) endpoint
- Drops down the list of prioritised endpoints based on availability
- Availability is based on configured status and endpoint monitoring

![](assets/1e-priority.png)


