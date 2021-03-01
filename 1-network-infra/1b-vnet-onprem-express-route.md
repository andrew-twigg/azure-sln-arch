# Connect on-prem network to Microsoft Global network with Express Route

## What is Express Route

- Extend on-prem networks into the cloud using a dedicated and private connection.
- Enables you to connect to cloud services like Azure, Office 365, and Dynamics 365.
- Enhances security, connections more reliable, reduced latency, increased throughput.

## Features and benefits

- Layer 3 (network layer) connectivity between on-prem network and Microsoft Cloud via connectivity partners.
- Build in redundancy.
- Dynamic Routing using Border Gateway protocol (BGP).

## When to use

- Low-latency connectivity to services in the cloud
- Access to high-volume systems in the cloud
- Consuming Microsoft Cloud Services like Office and Dynamics 365 for orgs with large numbers of users needing to access concurrently
- Orgs that migrated large-scale on-prem systems to Azure
- Keeping data off the public internet
- Large datacenters with high numbers of users and systems accessing SaaS offerings
- Mission-critical / enterprise-class workloads

## Connectivity Models

- CloudExchange co-location
- Point-to-point ethernet connection
- Any-to-Any (IPVPN) connection

## How it works

Supported across all regions and locations. Requires an ExpressRoute partner to provide the <i>edge service</i>, an authorized and authenticated connection that opertes through a partner-controlled router.

<i>Circuit</i> connections peer on-prem networks with vnets available through an endpoint in an ExpressRoute location, implemented by a Microsoft edge router).

A circuit provides a physical connection for transmitting data through the ExpressRoute provider's edge router to Microsoft edge routers. A circuit is established across a private wire.

Supports two peering schemes.

1. Private peering to connect to Azure IaaS and PaaS services deployed inside Azure vnets. Resources must have private IP addresses.
2. Microsoft peering to connect to Azure PaaS services, Office 365 services, and Dynamics 365.

There's also public peering, alowing connectivity to public addressess but it deprecated.

## HA

Two connections from the connectivity provider to two different Microsoft edge routers. This config is automatic and provides a degree of availability in a single location.

Consider circuits in different peering locations to provide HA and protect against regional outage.

Can also have multile circuits across different providers.

## ExpressRoute Direct and FastPath

ExpressRoute Direct - <i>Ultra-high-speed</i> option. Dual 100-Gbps connectivity. For massive and frequent data ingestion, and extreme scale.

FastPath - traffic directly to the VMs, bypassing the vnet gateway. Doesn't support vnet peering, or user defined routes on the gateway subnet.
