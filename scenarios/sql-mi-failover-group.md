# Add a SQL Managed Instance to a failover group

Note: this takes ages to run.

Ref. https://docs.microsoft.com/en-us/azure/azure-sql/managed-instance/failover-group-add-instance-tutorial?tabs=azure-powershell

- [Use CLI to create an Azure SQL Managed Instance](https://docs.microsoft.com/en-us/azure/sql-database/scripts/sql-database-create-configure-managed-instance-cli)
- [Use CLI to add an Azure SQL Managed Insstance to a failover group](https://docs.microsoft.com/en-us/azure/sql-database/scripts/sql-database-add-managed-instance-to-failover-group-cli)
- [Enabling subnet-delegation for new deployments](https://docs.microsoft.com/en-us/azure/azure-sql/managed-instance/subnet-service-aided-configuration-enable) - relates to the update on the subnets.
- [Enabling geo-replication between managed instances and their VNets](https://docs.microsoft.com/en-us/azure/azure-sql/database/auto-failover-group-overview?tabs=azure-powershell#enabling-geo-replication-between-managed-instances-and-their-vnets)


```sh
id=$RANDOM

rg=adt-rg-$id
loc=westeurope

forg=adt-rg-$id-fo
foloc=northeurope

az group create -g $rg -l $loc
az group create -g $forg -l $foloc

vnet=adt-vnet-$id
snet=adt-snet-$id
nsg=adt-nsg-$id
route=adt-route-$id
instance=adt-instance-$id

fovnet=adt-vnet-$id-fo
fosnet=adt-snet-$id-fo
fonsg=adt-nsg-$id-fo
foroute=adt-route-$id-fo
foinstance=adt-instance-$id-fo

login="sampleLogin"
password="sampleP@ssword123"

vpnSharedKey="abc123"

gateway=adt-dw-$id
gatewayIP=$gateway-ip
gatewayConnection=$gateway-connection

fogateway=adt-dw-$id-fo
fogatewayIP=$gateway-ip-fo
fogatewayConnection=$gateway-connection-fo

az network vnet create -g $rg -l $loc -n $vnet \
    --address-prefixes 10.0.0.0/16
az network vnet subnet create -g $rg -n $snet \
    --vnet-name $vnet \
    --address-prefixes 10.0.0.0/24

az network nsg create -g $rg -l $loc -n $nsg

az network nsg rule create -g $rg -n "allow_management_inbound" \
    --nsg-name $nsg \
    --priority 100 \
    --access Allow \
    --destination-address-prefixes 10.0.0.0/24 \
    --destination-port-ranges 9000 9003 1438 1440 1452 \
    --direction Inbound \
    --protocol Tcp \
    --source-address-prefixes "*" \
    --source-port-ranges "*"
az network nsg rule create -g $rg -n "allow_misubnet_inbound" \
    --nsg-name $nsg \
    --priority 200 \
    --access Allow \
    --destination-address-prefixes 10.0.0.0/24 \
    --destination-port-ranges "*" \
    --direction Inbound \
    --protocol "*" \
    --source-address-prefixes 10.0.0.0/24 \
    --source-port-ranges "*"
az network nsg rule create -g $rg -n "allow_health_probe_inbound" \
    --nsg-name $nsg \
    --priority 300 \
    --access Allow \
    --destination-address-prefixes 10.0.0.0/24 \
    --destination-port-ranges "*" \
    --direction Inbound \
    --protocol "*" \
    --source-address-prefixes AzureLoadBalancer \
    --source-port-ranges "*"
az network nsg rule create -g $rg -n "allow_management_outbound" \
    --nsg-name $nsg \
    --priority 1100 \
    --access Allow \
    --destination-address-prefixes AzureCloud \
    --destination-port-ranges 443 12000 \
    --direction Outbound \
    --protocol Tcp \
    --source-address-prefixes 10.0.0.0/24 \
    --source-port-ranges "*"
az network nsg rule create -g $rg -n "allow_misubnet_outbound" \
    --nsg-name $nsg \
    --priority 200 \
    --access Allow \
    --destination-address-prefixes 10.0.0.0/24 \
    --destination-port-ranges "*" \
    --direction Outbound \
    --protocol "*" \
    --source-address-prefixes 10.0.0.0/24 \
    --source-port-ranges "*"

az network route-table create -g $rg -n $route -l $loc
az network route-table route create -g $rg -n primaryToMIManagementService \
    --address-prefix 0.0.0.0/0 \
    --next-hop-type Internet \
    --route-table-name $route
az network route-table route create -g $rg -n ToLocalClusterNode \
    --address-prefix 10.0.0.0/24 \
    --next-hop-type VnetLocal \
    --route-table-name $route

az network vnet subnet update -g $rg -n $snet \
    --network-security-group $nsg \
    --route-table $route \
    --vnet-name $vnet 

az network vnet subnet update -g $rg -n $snet \
    --vnet-name $vnet \
    --delegations Microsoft.Sql/managedInstances

az sql mi create -g $rg -l $loc -n $instance \
    --admin-password $password \
    --admin-user $login \
    --subnet $snet \
    --vnet-name $vnet \
    --assign-identity

---
az network vnet create -g $forg -n $fovnet -l $foloc \
    --address-prefixes 10.128.0.0/16
az network vnet subnet create -g $forg -n $fosnet \
    --vnet-name $fovnet \
    --address-prefixes 10.128.0.0/24

az network nsg create -g $forg -l $foloc -n $fonsg

az network nsg rule create -g $forg -n "allow_management_inbound" \
    --nsg-name $fonsg \
    --priority 100 \
    --access Allow \
    --destination-address-prefixes 10.128.0.0/24 \
    --destination-port-ranges 9000 9003 1438 1440 1452 \
    --direction Inbound \
    --protocol Tcp \
    --source-address-prefixes "*" \
    --source-port-ranges "*"
az network nsg rule create -g $forg -n "allow_misubnet_inbound" \
    --nsg-name $fonsg \
    --priority 200 \
    --access Allow \
    --destination-address-prefixes 10.128.0.0/24 \
    --destination-port-ranges "*" \
    --direction Inbound \
    --protocol "*" \
    --source-address-prefixes 10.128.0.0/24 \
    --source-port-ranges "*"
az network nsg rule create -g $forg --n "allow_health_probe_inbound" \
    --nsg-name $fonsg \
    --priority 300 \
    --access Allow \
    --destination-address-prefixes 10.128.0.0/24 \
    --destination-port-ranges "*" \
    --direction Inbound \
    --protocol "*" \
    --source-address-prefixes AzureLoadBalancer \
    --source-port-ranges "*"
az network nsg rule create -g $forg -n "allow_management_outbound" \
    --nsg-name $fonsg \
    --priority 1100 \
    --access Allow \
    --destination-address-prefixes AzureCloud \
    --destination-port-ranges 443 12000 \
    --direction Outbound \
    --protocol Tcp \
    --source-address-prefixes 10.128.0.0/24 \
    --source-port-ranges "*"
az network nsg rule create -g $forg -n "allow_misubnet_outbound" \
    --nsg-name $fonsg \
    --priority 200 \
    --access Allow \
    --destination-address-prefixes 10.128.0.0/24 \
    --destination-port-ranges "*" \
    --direction Outbound \
    --protocol "*" \
    --source-address-prefixes 10.128.0.0/24 \
    --source-port-ranges "*"

az network route-table create -g $forg -n $foroute -l $foloc

az network route-table route create -g $forg -n primaryToMIManagementService \
    --address-prefix 0.0.0.0/0 \
    --next-hop-type Internet \
    --route-table-name $foroute
az network route-table route create -g $forg -n ToLocalClusterNode \
    --address-prefix 10.128.0.0/24 \
    --next-hop-type VnetLocal \
    --route-table-name $foroute

az network vnet subnet update -g $rg -n $fosnet \
    --network-security-group $fonsg \
    --route-table $foroute \
    --vnet-name $fovnet 

az sql mi create -g $rg -n $foinstance -l $foloc \
    --admin-password $password \
    --admin-user $login \
    --subnet $fosnet \
    --vnet-name $fovnet \
    --assign-identity

az network vnet subnet create -g $rg -n "GatewaySubnet" \
    --vnet-name $vnet \
    --address-prefixes 10.0.255.0/27
az network public-ip create -g $rg -n $gatewayIP -l $loc --allocation-method Dynamic
az network vnet-gateway create -g $rg -n $gateway -l $loc \
    --public-ip-addresses $gatewayIP \
    --vnet $vnet \
    --asn 61000 \
    --gateway-type Vpn \
    --sku VpnGw1 \
    --vpn-type RouteBased #-EnableBgp $true

echo "Creating failover gateway..."

az network vnet subnet create -g $forg -n "GatewaySubnet" \
    --vnet-name $fovnet \
    --address-prefixes 10.128.255.0/27
az network public-ip create -g $forg -n $fogatewayIP -l $foloc --allocation-method Dynamic
az network vnet-gateway create -g $forg -n $fogateway -l $foloc \
    --public-ip-addresses $fogatewayIP \
    --vnet $failoverVnet \
    --asn 62000 \
    --gateway-type Vpn \
    --sku VpnGw1 \
    --vpn-type RouteBased

az network vpn-connection create -g $rg -n $gatewayConnection \
    --vnet-gateway1 $gateway \
    --enable-bgp \
    --vnet-gateway2 $fogateway \
    --shared-key $vpnSharedKey
az network vpn-connection create -g $rg -n $fogatewayConnection -l $foloc \
    --vnet-gateway1 $fogateway \
    --enable-bgp \
    --shared-key $vpnSharedKey \
    --vnet-gateway2 $gateway

```

TODO: I didn't complete this because it took hours to provision. Also the approach might be out of date because since Oct '20 [peering is now supported for failover of managed instances](https://azure.microsoft.com/en-us/updates/global-virtual-network-peering-support-for-azure-sql-managed-instance-now-available/). Is this the [documentation](https://docs.microsoft.com/en-us/azure/azure-sql/database/auto-failover-group-overview?tabs=azure-powershell#enabling-geo-replication-between-managed-instances-and-their-vnets)?
