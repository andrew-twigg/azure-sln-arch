# Bastion in peered VNet

## References

- [Create an Azure Bastion host using CLI](https://docs.microsoft.com/en-us/azure/bastion/create-host-cli)
- [Create the peered VNet scenario](../1-network-infra/1d-vnet-peering.md)


## Setup

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

vnet1=adt-vnet-$id-1
vnet2=adt-vnet-$id-2
vnet3=adt-vnet-$id-3

snet1=adt-snet-$id-1
snet2=adt-snet-$id-2

vm1=adt-vm-$id-1
vm2=adt-vm-$id-2
vm3=adt-vm-$id-3

echo $rg

az group create -g $rg -l $loc

az network vnet create -g $rg -l $loc -n $vnet1 \
    --address-prefix 10.1.0.0/16 \
    --subnet-name $snet1 \
    --subnet-prefix 10.1.1.0/24
az network vnet create -g $rg -l $loc -n $vnet2 \
    --address-prefix 10.2.0.0/16 \
    --subnet-name $snet1 \
    --subnet-prefix 10.2.1.0/24 
az network vnet create -g $rg -l northeurope -n $vnet3 \
    --address-prefix 10.3.0.0/16 \
    --subnet-name $snet2 \
    --subnet-prefix 10.3.1.0/24

az network vnet list -o table

password=Pas5w0rd123456

az vm create -g $rg -l $loc -n $vm1 --image UbuntuLTS --no-wait \
    --vnet-name $vnet1 \
    --subnet $snet1 \
    --admin-username azureuser \
    --admin-password $password
az vm create -g $rg -l $loc -n $vm2 --image UbuntuLTS --no-wait \
    --vnet-name $vnet2 \
    --subnet $snet1 \
    --admin-username azureuser \
    --admin-password $password
az vm create -g $rg -l northeurope -n $vm3 --image UbuntuLTS --no-wait \
    --vnet-name $vnet3 \
    --subnet $snet2 \
    --admin-username azureuser \
    --admin-password $password

az vm list -g $rg --show-details --query '[*].{Name:name, ProvisioningState:provisioningState}' -o table

az network vnet peering create -g $rg -n $vnet1-to-$vnet2 --allow-vnet-access \
    --vnet-name $vnet1 \
    --remote-vnet $vnet2
az network vnet peering create -g $rg -n $vnet2-to-$vnet1 --allow-vnet-access \
    --vnet-name $vnet2 \
    --remote-vnet $vnet1
az network vnet peering create -g $rg -n $vnet2-to-$vnet3 --allow-vnet-access \
    --vnet-name $vnet2 \
    --remote-vnet $vnet3
az network vnet peering create -g $rg -n $vnet3-to-$vnet2 --allow-vnet-access \
    --vnet-name $vnet3 \
    --remote-vnet $vnet2

az network vnet peering list -g $rg --vnet-name $vnet1 -o table
az network vnet peering list -g $rg --vnet-name $vnet2 -o table
az network vnet peering list -g $rg --vnet-name $vnet3 -o table

az network nic show-effective-route-table -g $rg -n "$vm1"VMNic -o table
az network nic show-effective-route-table -g $rg -n "$vm2"VMNic -o table
az network nic show-effective-route-table -g $rg -n "$vm3"VMNic -o table
```

You can now ssh across the machines...

```sh
ssh -o StrictHostKeyChecking=no azureuser@<vm1 public IP>
ssh -o StrictHostKeyChecking=no azureuser@<vm2 private IP>
ssh -o StrictHostKeyChecking=no azureuser@<vm3 private IP>
```

But from vm3, not...

```sh
ssh -o StrictHostKeyChecking=no azureuser@<vm1 private IP>
```

## Bastion

```sh
vnetbastion=adt-vnet-$id-bastion
snetbastion=adt-snet-$id-bastion
pipbastion=adt-pip-$id-bastion

az network vnet create -g $rg -l $loc -n $vnetbastion \
    --address-prefix 10.4.0.0/24 \
    --subnet-name $snetbastion \
    --subnet-prefix 10.4.0.0/27

az network public-ip create -g $rg -n $pipbastion -l $loc --sku Standard

# This not working!
az network bastion create -g $rg -l $loc -n adt-bastion-$id \
    --public-ip-address $pipbastion \
    --vnet-name $vnetbastion

(InvalidResourceReference) Resource /subscriptions/b70490c4-40b2-4066-afc9-05b797168001/resourceGroups/adt-rg-2210/providers/Microsoft.Network/virtualNetworks/adt-vnet-2210-bastion/subnets/AzureBastionSubnet referenced by resource /subscriptions/b70490c4-40b2-4066-afc9-05b797168001/resourceGroups/adt-rg-2210/providers/Microsoft.Network/bastionHosts/adt-bastion-2210 was not found. Please make sure that the referenced resource exists, and that both resources are in the same region.
```

So got that error. Can configure it in the portal. Is it because the bastion needs to be in the address space of the vnet1?

Configured from the portal, on VM1, can connect to VM1. Also VM2 because of the peering. Can't connect to VM3 because its not transitive.
