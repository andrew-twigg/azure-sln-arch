# Active Directory forest demo environment on Azure

Installs a new AD forest using Azure CLI on Azure to support Hybrid Identity scenarios.


## References

- [Install a new Active Directory forest using Azure CLI](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/virtual-dc/adds-on-azure-vm)
- [Install Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-#BKMK_PS)


## Environment

Creates: 

- resource group
- networking, vnet, subnet, nsg and rules for RDP
- Azure VM availability set to host AD DS
- two VMs to run AD DS and DNS


```sh
Location=westeurope
RG=adt-rg-$RANDOM
NetworkSecurityGroup=adt-nsg-dcs
VNetName=adt-vnet-$RANDOM
VNetAddress=10.10.0.0/16
SubnetName=adt-snet-dcs
SubnetAddress=10.10.10.0/24
AvailabilitySet=adt-aset-dcs
VMSize=Standard_DS1_v2
DataDiskSize=20
AdminUsername=azureuser
AdminPassword=ChangeMe123456
DomainController1=AZDC01
DC1IP=10.10.10.11
DomainController2=AZDC02
DC2IP=10.10.10.12

# Create a resource group.
az group create \
    -n $RG \
    -l $Location

# Create a network security group
az network nsg create \
    -n $NetworkSecurityGroup \
    -g $RG \
    -l $Location

# Create a network security group rule for port 3389.
az network nsg rule create \
    --resource-group $RG \
    --name PermitRDP \
    --nsg-name $NetworkSecurityGroup \
    --priority 1000 \
    --access Allow \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --direction Inbound \
    --destination-port-ranges 3389

# Create a virtual network.
az network vnet create \
    --name $VNetName \
    --resource-group $RG \
    --address-prefixes $VNetAddress \
    --location $Location

# Create a subnet
az network vnet subnet create \
    --address-prefix $SubnetAddress \
    --name $SubnetName \
    --resource-group $RG \
    --vnet-name $VNetName \
    --network-security-group $NetworkSecurityGroup

# Create an availability set.
az vm availability-set create \
    --name $AvailabilitySet \
    --resource-group $RG \
    --location $Location

# Create two virtual machines.
az vm create \
    --resource-group $RG \
    --availability-set $AvailabilitySet \
    --name $DomainController1 \
    --size $VMSize \
    --image Win2019Datacenter \
    --admin-username $AdminUsername \
    --admin-password $AdminPassword \
    --data-disk-sizes-gb $DataDiskSize \
    --data-disk-caching None \
    --nsg $NetworkSecurityGroup \
    --private-ip-address $DC1IP \
    --no-wait

az vm create \
    --resource-group $RG \
    --availability-set $AvailabilitySet \
    --name $DomainController2 \
    --size $VMSize \
    --image Win2019Datacenter \
    --admin-username $AdminUsername \
    --admin-password $AdminPassword \
    --data-disk-sizes-gb $DataDiskSize \
    --data-disk-caching None \
    --nsg $NetworkSecurityGroup \
    --private-ip-address $DC2IP
```

Follow the AD DS forest setup guide [here](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/virtual-dc/adds-on-azure-vm)
