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


