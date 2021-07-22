# Quickstart: Create a public load balancer to load balance VMs using CLI

Ref. [docs](https://docs.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-cli?tabs=option-1-create-load-balancer-standard)


```sh
RG=adt-rg-$RANDOM
az group create -g $RG -l westeurope

az network vnet create \
    -g $RG \
    -l westeurope \
    -n myVNet \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name myBackendSubnet \
    --subnet-prefixes 10.1.0.0/24

az network public-ip create \
    -g $RG \
    -n myBastionIP \
    --sku Standard

az network vnet subnet create \
    -g $RG \
    -n AzureBastionSubnet \
    --vnet-name myVNet \
    --address-prefixes 10.1.1.0/24

az network bastion create \
    -g $RG \
    -n myBastionHost \
    --public-ip-address myBastionIP \
    --vnet-name myVNet \
    -l westeurope

az network nsg create \
    -g $RG \
    -n myNSG

az network nsg rule create \
    -g $RG \
    --nsg-name myNSG \
    -n myNSGRuleHTTP \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 200

# array=(myNicVM1, myNicVM2, myNicVM3)
# for vmnic in "${array[@]}"
# do
#     az network nic create \
#         -g $RG \
#         -n $vmnic \
#         --vnet-name myVNet \
#         --subnet myBackEndSubnet \
#         --network-security-group myNSG
# done

az network nic create -g $RG -n myNicVM1 --vnet-name myVNet --subnet myBackEndSubnet --network-security-group myNSG
az network nic create -g $RG -n myNicVM2 --vnet-name myVNet --subnet myBackEndSubnet --network-security-group myNSG
az network nic create -g $RG -n myNicVM3 --vnet-name myVNet --subnet myBackEndSubnet --network-security-group myNSG


az vm create \
    -g $RG \
    -n myVM1 \
    --nics myNicVM1 \
    --image win2019datacenter \
    --admin-username azureuser \
    --zone 1 \
    --no-wait
az vm create \
    -g $RG \
    -n myVM2 \
    --nics myNicVM2 \
    --image win2019datacenter \
    --admin-username azureuser \
    --zone 2 \
    --no-wait
az vm create \
    -g $RG \
    -n myVM3 \
    --nics myNicVM3 \
    --image win2019datacenter \
    --admin-username azureuser \
    --zone 3 \
    --no-wait

az network public-ip create \
    -g $RG \
    -n myPublicIP \
    --sku Standard

az network lb create \
    -g $RG \
    -n myLoadBalancer \
    --sku Standard \
    --public-ip-address myPublicIP \
    --frontend-ip-name myFrontEnd \
    --backend-pool-name myBackEndPool

az network lb probe create \
    -g $RG \
    --lb-name myLoadBalancer \
    -n myHealthProbe \
    --protocol tcp \
    --port 80

az network lb rule create \
    -g $RG \
    --lb-name myLoadBalancer \
    -n myHTTPRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name myFrontEnd \
    --backend-pool-name myBackEndPool \
    --probe-name myHealthProbe \
    --disable-outbound-snat true \
    --idle-timeout 15 \
    --enable-tcp-reset true

az network nic ip-config address-pool add \
    --address-pool myBackendPool \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM1 \
    -g $RG \
    --lb-name myLoadBalancer
az network nic ip-config address-pool add \
    --address-pool myBackendPool \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM2 \
    -g $RG \
    --lb-name myLoadBalancer
az network nic ip-config address-pool add \
    --address-pool myBackendPool \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM3 \
    -g $RG \
    --lb-name myLoadBalancer

az network public-ip create \
    -g $RG \
    -n myPublicIPOutbound \
    --sku Standard

az network public-ip prefix create \
    -g $RG \
    -n myPublicIPPrefixOutbound \
    --length 30

az network lb frontend-ip create \
    -g $RG \
    -n myFrontEndOutbound \
    --lb-name myLoadBalancer \
    --public-ip-address myPublicIPOutbound

az network lb address-pool create \
    -g $RG \
    --lb-name myLoadBalancer \
    -n myBackendPoolOutbound

az network lb outbound-rule create \
    -g $RG \
    --lb-name myLoadBalancer \
    -n myOutboundRule \
    --frontend-ip-configs myFrontEndOutbound \
    --protocol All \
    --idle-timeout 15 \
    --outbound-ports 10000 \
    --address-pool myBackEndPoolOutbound

az network nic ip-config address-pool add \
    --address-pool myBackendPoolOutbound \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM1 \
    --resource-group $RG \
    --lb-name myLoadBalancer
az network nic ip-config address-pool add \
    --address-pool myBackendPoolOutbound \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM2 \
    --resource-group $RG \
    --lb-name myLoadBalancer
az network nic ip-config address-pool add \
    --address-pool myBackendPoolOutbound \
    --ip-config-name ipconfig1 \
    --nic-name myNicVM3 \
    --resource-group $RG \
    --lb-name myLoadBalancer

az vm extension set \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --name CustomScriptExtension \
    --vm-name myVM1 \
    --resource-group $RG \
    --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

az vm extension set \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --name CustomScriptExtension \
    --vm-name myVM2 \
    --resource-group $RG \
    --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

az vm extension set \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --name CustomScriptExtension \
    --vm-name myVM3 \
    --resource-group $RG \
    --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

az network public-ip show \
    -g $RG \
    --name myPublicIP \
    --query ipAddress \
    -o tsv
```
