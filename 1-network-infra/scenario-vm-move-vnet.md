# Moving VM from one VNET to another

Scenario: Azure subscription named Subscription1. Supscription1 contains the resources in the following table.


| Name  | Type            |
| ----  | ----            |
| RG1   | Resource Group  |
| RG2   | Resource Group  |
| VNet1 | Virtual Network |
| VNet2 | Virtual Networl |


VNet1 is in RG1. VNet2 is in RG2. There is no connectivity between VNet1 and VNet2.
An administrator named Admin1 creates an Azure virtual machine named VM1 in RG1. VM1 uses a disk named Disk1 and connects to VNet1. Admin1 then installs a custom application in VM1.
You need to move the custom application to VNet2.

Script below tries to create a new nic in RG2 and attach that to the VM in RG1 which doesn't work. You can't allocate the nic to the VM when the nic is in a different resource group.


```sh
az group create -g $RG1 -l westeurope
az group create -g $RG2 -l westeurope
az group list --query '[].name' -o table

VN1=adt-vnet1-$RANDOM
VN2=adt-vnet2-$RANDOM

echo $VN1
echo $VN2

az network vnet create \
    -g $RG1 \
    -n $VN1 \
    --address-prefix 10.1.0.0/16 \
    --subnet-name Apps \
    --subnet-prefix 10.1.1.0/24 \
    -l westeurope

az network vnet create \
    -g $RG2 \
    -n $VN2 \
    --address-prefix 10.2.0.0/16 \
    --subnet-name Marketing \
    --subnet-prefix 10.2.1.0/24 \
    -l westeurope

az network vnet list -o table

az vm create \
    -g $RG1 \
    --no-wait \
    -n VM1 \
    -l westeurope \
    --vnet-name $VN1 \
    --subnet Apps \
    --image UbuntuLTS \
    --admin-username azureuser \
    --admin-password $password

az vm list \
    -g $RG1 \
    -d \
    --query "[].{Name:name, ProvisioningState:provisioningState, PowerStste:powerState}" \
    -o table

az vm deallocate -g $RG1 --name VM1

az vm nic list -g $RG1 --vm-name VM1
az network nic create \
    -g $RG2 \
    --vnet-name $VN2 \
    --subnet Marketing \
    -n VM1VMNic2
```

Adding to the VM fails...

```sh
az vm nic add -g $RG1 --vm-name VM1 --nics VM1VMNic2

(ResourceNotFound) The Resource 'Microsoft.Network/networkInterfaces/VM1VMNic2' under resource group 'adt-rg1-25450' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix

az vm nic add -g $RG2 --vm-name VM1 --nics VM1VMNic2
(ResourceNotFound) The Resource 'Microsoft.Compute/virtualMachines/VM1' under resource group 'adt-rg2-495' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix
```sh


