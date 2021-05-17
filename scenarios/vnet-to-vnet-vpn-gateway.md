# Configure a VNet-to-VNet VPN gateway connection using Azure CLI

Ref. https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-vnet-vnet-cli

- connect vnets using VNet-to-VNet connection type
- vnets can be in same or different regions, and same or different subs
- subs don't need to be associated with the same AD tenant

When you create a VNet-to-VNet connection, you do not see the local network gateway address space. It is automatically created and populated. If you update the address space for one VNet, the other automatically knows to route to the updated address space.

Consider VNet peering instead.


```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

vnet1=adt-vnet-$id-1
vnet1pip=adt-pip-$id-1
vnet1gw=adt-gw-$id-1

rg4=$rg-4
vnet4=adt-vnet-$id-4
vnet4pip=adt-pip-$id-4
vnet4gw=adt-gw-$id-4
loc4=northeurope


az group create -g $rg -l $loc

az network vnet create -g $rg -l $loc -n $vnet1 \
    --address-prefix 10.11.0.0/16 \
    --subnet-name FrontEnd \
    --subnet-prefix 10.11.0.0/24
az network vnet update -g $rg -n $vnet1 \
    --address-prefixes 10.11.0.0/16 10.12.0.0/16 
az network vnet subnet create -g $rg -n BackEnd \
    --vnet-name $vnet1 \
    --address-prefix 10.12.0.0/24
az network vnet subnet create -g $rg -n GatewaySubnet \
    --vnet-name $vnet1 \
    --address-prefix 10.12.255.0/27
az network public-ip create -g $rg -n $vnet1pip \
    --allocation-method Dynamic
az network vnet-gateway create -g $rg -l $loc -n $vnet1gw \
    --public-ip-address $vnet1pip \
    --vnet $vnet1 \
    --gateway-type Vpn \
    --sku VpnGw1 \
    --vpn-type RouteBased \
    --no-wait


az group create -g $rg4 -l $loc4

az network vnet create -g $rg4 -n $vnet4 -l $loc4 \
    --address-prefix 10.41.0.0/16 \
    --subnet-name FrontEnd \
    --subnet-prefix 10.41.0.0/24
az network vnet update -g $rg4 -n $vnet4 \
    --address-prefixes 10.41.0.0/16 10.42.0.0/16
az network vnet subnet create -g $rg4 -n BackEnd \
    --vnet-name $vnet4 \
    --address-prefix 10.42.0.0/24
az network vnet subnet create -g $rg4 -n GatewaySubnet  \
    --vnet-name $vnet4 \
    --address-prefix 10.42.255.0/27
az network public-ip create -g $rg4 -n $vnet4pip \
    --allocation-method Dynamic
az network vnet-gateway create -g $rg4 -l $loc4 -n $vnet4gw \
    --public-ip-address $vnet4pip \
    --vnet $vnet4 \
    --gateway-type Vpn \
    --sku VpnGw1 \
    --vpn-type RouteBased \
    --no-wait
```

Connect the vnets...

```sh
vnet1gwid=$(az network vnet-gateway show -g $rg -n $vnet1gw --query id -o tsv)
vnet4gwid=$(az network vnet-gateway show -g $rg4 -n $vnet4gw --query id -o tsv)

az network vpn-connection create -g $rg -l $loc -n VNet1ToVnet4 \
    --vnet-gateway1 $vnet1gwid \
    --shared-key "aabbcc" \
    --vnet-gateway2 $vnet4gwid
az network vpn-connection create -g $rg4 -l $loc4 -n VNet4ToVnet1 \
    --vnet-gateway1 $vnet4gwid \
    --shared-key "aabbcc" \
    --vnet-gateway2 $vnet1gwid    

# Verify...
az network vpn-connection show -g $rg -n VNet1toVnet4 
```
