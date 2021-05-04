# Quickstart: Create an internal load balancer by using Azure CLI

Ref [docs](https://docs.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-internal-cli?tabs=option-1-create-load-balancer-standard)

```sh
RG=adt-rg-$RANDOM
az group create -g $RG -l westeurope

VNET=myVNet
SNET_BACKEND=myBackendSubnet
az network vnet create \
    -g $RG \
    -l westeurope \
    -n $VNET \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name $SNET_BACKEND \
    --subnet-prefixes 10.1.0.0/24

az network public-ip create \
    -g $RG \
    -n myBastionIP \
    --sku Standard

az network vnet subnet create \
    -g $RG \
    -n AzureBastionSubnet \
    --vnet-name $VNET \
    --address-prefixes 10.1.1.0/24

az network bastion create \
    -g $RG \
    -n myBastionHost \
    --public-ip-address myBastionIP \
    --vnet-name $VNET \
    -l westeurope

NSG=myNSG
az network nsg create \
    -g $RG \
    -n $NSG

az network nsg rule create \
    -g $RG \
    --nsg-name $NSG \
    --name myNSGRuleHTTP \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 200


# TODO: why don't loops work? Complains about the name even though it correct in the error.
array=(myNicVM1, myNicVM2, myNicVM3)
for vmnic in "${array[@]}"
do
    az network nic create -g $RG -n $vmnic --vnet-name $VNET --subnet $SNET_BACKEND --network-security-group $NSG
done

az network nic create -g $RG -n myNicVM1 --vnet-name $VNET --subnet $SNET_BACKEND --network-security-group $NSG
az network nic create -g $RG -n myNicVM2 --vnet-name $VNET --subnet $SNET_BACKEND --network-security-group $NSG
az network nic create -g $RG -n myNicVM3 --vnet-name $VNET --subnet $SNET_BACKEND --network-security-group $NSG

az vm create -g $RG -n myVM1 \
    --nics myNicVM1 \
    --image win2019datacenter \
    --admin-username azureuser \
    --zone 1 \
    --no-wait

az vm create -g $RG -n myVM2 \
    --nics myNicVM2 \
    --image win2019datacenter \
    --admin-username azureuser \
    --zone 2 \
    --no-wait

az vm create -g $RG -n myVM3 \
    --nics myNicVM3 \
    --image win2019datacenter \
    --admin-username azureuser \
    --zone 3 \
    --no-wait

az network lb create -g $RG -n myLoadBalancer \
    --sku Standard \
    --vnet-name $VNET \
    --subnet $SNET_BACKEND \
    --frontend-ip-name myFrontEnd \
    --backend-pool-name myBackEndPool

az network lb probe create -g $RG -n myHealthProbe \
    --lb-name myLoadBalancer \
    --protocol tcp \
    --port 80

az network lb rule create -g $RG -n myHTTPRule \
    --lb-name myLoadBalancer \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name myFrontEnd \
    --backend-pool-name myBackEndPool \
    --probe-name myHealthProbe \
    --idle-timeout 15 \
    --enable-tcp-reset true

az network nic ip-config address-pool add -g $RG \
    --address-pool myBackendPool \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM1 \
    --lb-name myLoadBalancer
az network nic ip-config address-pool add -g $RG \
    --address-pool myBackendPool \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM2 \
    --lb-name myLoadBalancer
az network nic ip-config address-pool add -g $RG \
    --address-pool myBackendPool \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM3 \
    --lb-name myLoadBalancer 
```

Testing the load balancer...

```sh
az network nic create -g $RG -n myNicTestVM \
    --vnet-name $VNET \
    --subnet $SNET_BACKEND \
    --network-security-group myNSG

az vm create -g $RG -n myTestVM \
    --nics myNicTestVM \
    --image Win2019Datacenter \
    --admin-username adminuser \
    --no-wait

az vm extension set -g $RG \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --name CustomScriptExtension \
    --vm-name myVM1 \
    --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
az vm extension set -g $RG \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --name CustomScriptExtension \
    --vm-name myVM2 \
    --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
az vm extension set -g $RG \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --name CustomScriptExtension \
    --vm-name myVM3 \
    --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
```
