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
VNetAddress=10.15.0.0/16
SubnetName=adt-snet-dcs
SubnetAddress=10.15.10.0/24
AvailabilitySet=adt-aset-dcs
VMSize=Standard_DS1_v2
DataDiskSize=20
AdminUsername=azureuser
AdminPassword=ChangeMe123456
DomainController1=AZDC01
DC1IP=10.15.10.11
DomainController2=AZDC02
DC2IP=10.15.10.12

az group create \
    -n $RG \
    -l $Location
az network nsg create \
    -n $NetworkSecurityGroup \
    -g $RG \
    -l $Location
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
az network vnet create \
    --name $VNetName \
    --resource-group $RG \
    --address-prefixes $VNetAddress \
    --location $Location
az network vnet subnet create \
    --address-prefix $SubnetAddress \
    --name $SubnetName \
    --resource-group $RG \
    --vnet-name $VNetName \
    --network-security-group $NetworkSecurityGroup
az vm availability-set create \
    --name $AvailabilitySet \
    --resource-group $RG \
    --location $Location
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
az vm run-command invoke \
    --command-id RunPowerShellScript \
    --name $DomainController1 \
    --resource-group $RG \
    --scripts "Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS"
az vm run-command invoke \
    --command-id RunPowerShellScript \
    --name $DomainController2 \
    --resource-group $RG \
    --scripts "Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS"
```


### Configure the first domain controller

```sh
az vm run-command invoke \
    --command-id RunPowerShellScript \
    --name $DomainController1 \
    --resource-group $RG \
    --scripts @adds-forest-create.ps1 \
    --parameters "DomainName=contoso.com" "DomainNetBIOSName=CONTOSO"
```

### [Configure DNS](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/virtual-dc/adds-on-azure-vm#configure-dns)

Set the primary and secondary DNS servers for the VNet.

```sh
az network vnet update \
    --resource-group $RG \
    --name $VNetName \
    --dns-server $DC1IP $DC2IP
```


### Configure the second domain controller

```sh
az vm run-command invoke \
    --command-id RunPowerShellScript \
    --name $DomainController2 \
    --resource-group $RG \
    --scripts @adds-forest-create.ps1 \
    --parameters "DomainName=contoso.com" "DomainNetBIOSName=CONTOSO"
```

[At this point](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/virtual-dc/adds-on-azure-vm#wrap-up) the environment has a pair of domain controllers, and we have configured the Azure virtual network so that additional servers may be added to the environment.

