# Filter network traffic

Uses a NSG to filter network traffic inbound and outbound from a subnet.

Ref. Tutorial [Filter network traffic](https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-filter-network-traffic)

```sh
RG=adt-rg-$RANDOM

az group create -g $RG -l eastus
az group show -g $RG --query "properties.provisioningState"

az network vnet create \
    -g $RG \
    -n myVNet \
    -l eastus \
    --address-prefix 10.2.0.0/16 \
    --subnet-name Services \
    --subnet-prefix 10.2.0.0/24

# App security groups enables grouping of servers with similar functions.
az network asg create -g $RG -n myAsgWebServers -l eastus
az network asg create -g $RG -n myAsgMgmtServers -l eastus

az network nsg create -g $RG -n myNSG -l eastus

az network vnet subnet update \
    -g $RG \
    -n Services \
    --vnet-name myVNet \
    --network-security-group myNSG

# Allows ports 80 and 443 to the myAsgWebServers ASG
az network nsg rule create \
    -g $RG \
    --nsg-name myNSG \
    --name Allow-Web-All \
    --direction Inbound \
    --priority 100 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-asgs "myAsgWebServers" \
    --destination-port-ranges 80 443 \
    --access Allow \
    --protocol Tcp \
    --description "Allow inbound web"

# DON'T do this in real life!
# RDP port 3389 is exposed to the Internet.
# This is only recommended for testing. For production environments, use a VPN or private connection.
az network nsg rule create \
    -g $RG \
    --nsg-name myNSG \
    --name Allow-RDP-All \
    --direction Inbound \
    --priority 110 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-asgs "myAsgMgmtServers" \
    --destination-port-ranges 3389 \
    --access Allow \
    --protocol Tcp \
    --description "Allow RDP"

az vm create \
    -g $RG \
    -l eastus \
    --name myVMWeb \
    --image Win2019Datacenter \
    --size Standard_DS1_v2 \
    --admin-username azureuser \
    --admin-password Pas5w0rd123456 \
    --vnet-name myVNet \
    --subnet Services \
    --nsg ""
az vm create \
    -g $RG \
    -l eastus \
    --name myVMMgmt \
    --image Win2019Datacenter \
    --size Standard_DS1_v2 \
    --admin-username azureuser \
    --admin-password Pas5w0rd123456 \
    --vnet-name myVNet \
    --subnet Services \
    --nsg ""

WEBSERVERIP="$(az vm list-ip-addresses \
    --resource-group $RG \
    --name myVMWeb \  
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)"

az network nic ip-config update \
    -g $RG \
    -n ipconfigmyVMWeb \
    --nic-name myVMWebVMNic \
    --application-security-groups myAsgWebServers
az network nic ip-config update \
    -g $RG \
    -n ipconfigmyVMMgmt \
    --nic-name myVMMgmtVMNic \
    --application-security-groups myAsgMgmtServers

```


