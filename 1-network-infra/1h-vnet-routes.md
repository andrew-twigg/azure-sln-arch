# Manage and control traffic flow in Azure deployment with routes

## Learning objectives

Control Azure vnet traffic by implementing custom routes.

- Routing capabilities of Azure vnet
- Routing config
- Deployment
- Routing config to send traffic through a network virtual appliance (NVA)


## Azure routing

Network traffic in Azure is automatically routed across Azure subnets, vnetsm and on-prem networks. This is controlled by system routes which are assigned by default to each subnet in a vnet.

Any Azure VM deployed to a vnet can communicate with all other VMs in subnets in that network, and potentially from on-prem through hybrid network of the internet.

- System routes can't be created or deleted
- System routes can be overridden by adding custom route

Subnet system routes:

| Address prefix                | Next hop type   |
| :---                          | :----:          |
| Unique to the virtual network | Virtual network |
| 0.0.0.0/0	                    | Internet        |
| 10.0.0.0/8                    | None            |
| 172.16.0.0/12                 | None            |
| 192.168.0.0/16                | None            |
| 100.64.0.0/10                 | None            |

&nbsp;
&nbsp;

Next hop type is network path taken by traffic sent to each address prefix.

- Virtual network: route created in the address prefix, representing each address range created at the vnet level. With multiple ranges specified, multiple routes created for each range.
- Internet: default system route 0.0.0.0/0 routes any address range to the internet, unless overridden with a custom route.
- None: Any traffic dropped and doesn't get routed outside the subnet. 100.64.0.0/10 for shared address space is also added.

&nbsp;
&nbsp;

![](assets/1h-system-routes-subnets-internet.svg)

Additional system routes are created if the following capabilities are enabled:

- vnet peering
- service chaining
- vnet gateway
- vnet service endpoint


## VNet peering and service chaining

- let vnets be connected to one another
- VMs can communicate in same region or across regions
- creates additional routes within the default route table

Service chaining lets you override these routes by creating user-defined routes between peered networks.

VNets with peering configured with user defined routes routing traffic through an NVA or an Azure VPN gateway.

![](assets/1h-virtual-network-peering-udrs.svg)

&nbsp;
&nbsp;

## VNet gateway

VNet gateways used to send encrypted traffic between Azure and on-prem over the internet and between Azure networks. A vnet gateway contains route tables and gateway services.

![](assets/1h-virtual-network-gateway.svg)


## VNet service endpoint

Extend private address space in Azure by providing a direct connection to Azure resources. Restricts flow of traffic. Azure creates routes in the route table to direct traffic.

&nbsp;
&nbsp;

# Custom Routes

Used to control traffic flow within a network. Like, route traffic through NVAs or firewall. Two options for implementing custom routes:

1. user-defined route
2. BGP


## User-defined routes

Overrides the default system routes so that traffic can be routed through firewalls or NVAs. 

Hop type options:
- <b>Virtual appliance</b> typically used to analyse or filter traffic that is entering/leaving a network.
- <b>VNet gateway</b> to indicate when routes for a specific address are to be routed to a vnet gateway. VNet gateway is specified as a VPN for the next hop type.
- <b>VNet</b> to override the default system route within a virtual network.
- <b>Internet</b> to route traffic to a specified address prefix that is routed to the internet.
- <b>None</b> to drop traffic sent to a specified address space.

Can't specify the next hop type <b>VirtualNetworkServiceEndpoint</b> which indicates vnet peering.


## Border Gateway Protocol (BGP)

Network gateways in on-prem networks can exchange routes with a vnet gateway in Azure using [BGP](https://en.wikipedia.org/wiki/Border_Gateway_Protocol), standard routing protocol.

[RFC 1105](https://tools.ietf.org/html/rfc1105), BGP is an inter-autonomous system routing protocol, primarily for exchange of network reachability information with other BGP systems. This includes information on the autonomous systems (AS's) that traffic must transmit to reach these networks. The information is sufficient to construct a graph of AS connectivity from which routing loops may be pruned and policy decisions at the AS level may be enforced. Runs on a reliable transport level protocol, based on but not limited to TCP. Uses port 179.

[RFC 4271](https://tools.ietf.org/html/rfc4271), BGP4 is current version, with support for CIDR and route aggregation.

Typically use BGP to advertise on-prem routes to Azure when connected to an Azure datacenter through ExpressRoute, but also using VPN site-to-site connection.

Offers network stability because routers can quickly change connections to send packets if a connection path goes down.

## Route selection and priority

If multiple routes are available in a route table, Azure uses the route with the longest prefix match. Example, if a message is sent to 10.0.0.2, but two routes are available with 10.0.0.0/16 and 10.0.0.0/24 prefixes, then Azure selects the route with 10.0.0.0/24 because its more specific. Means can select the intended address more quickly.

Can't configure multiple user-defined routes with the same address prefix. Azure selects the route based on its type in the following order of priority.

1. User-defined routes
2. BGP routes
3. System routes




