# Distribute services across Azure VNets and integrate them using VNet peering

Use VNet peering to enable comms across VNets in a way thats secure and minimally complex.

- Use cases for VNet peering
- Features and limitations of VNet peering
- Configure peering connections

Easy to implement and deploy, works well across regions / subs. Should be first choice when integrating Azure networks. Might not be best options if you have ExpressRoute, or VPN connections, or services behind Azure Basic Load Balancers that would be accessed from a peered VNet. 

VNet peering directly connects VNets so that VMs in the networks can communicate with each other as if they were in the same network.

Peered VNet traffic is routed between VMs through the Azure network, using only private IP addresses. No reliance on internet connectivity, gateways, or encrypted connections. 

- Traffic always private
- On backbone (high bandwidth / low latency connection)

Two types of peering connections:

1. VNet peering - same region VNet peering
2. Global VNet peering - different Azure regions

Reciprocal connections connect VNets together.

Cross-subscription VNet peering supports peering of VNets in different subs, using the same of different AD tenants. With different tenants, must grant peer subs <i>Network Contributor</i> role on both sides.

Peered VNets can only communicate with each other, not with peers of peers (non-transitive).

Gateway transit - Transitive connections on-prem using VNet gateways as transit points. Can enable on-prem connectivity without deploying VNet gateways to all VNets. Can reduce cost and complexity.

## Overlapping address spaces

IP address spaces of connected networks within Azure and between Azure and on-prem systems can't overlap, same for peered networks.

## Alternative connectivity methods

Other methods mainly for on-prem to Azure networks.

- ExpressRoute circuit
- VPNs (higher latency / more complex to manage / more costly)

When VNets are connected through both a gateway and VNet peering, traffic flows through peering connection.

 
