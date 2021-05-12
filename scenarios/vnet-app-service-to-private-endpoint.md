# Integrate an App Service to a Key Vault isolated to a VNet using Private Link

## References

- [Integrate your app with an Azure virtual network](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet)
- [Using Private Endpoints for Azure Web App](https://docs.microsoft.com/en-us/azure/app-service/networking/private-endpoint)
- [Integrate Key Vault with Azure Private Link](https://docs.microsoft.com/en-us/azure/key-vault/general/private-link-service?tabs=portal)
- [az webapp vnet-integration](https://docs.microsoft.com/en-us/cli/azure/webapp/vnet-integration?view=azure-cli-latest)

## Approach

- Key Vault integrated with Private Link and non-internet-routable.
- Ref. [WebApps Private Endpoint overview](https://docs.microsoft.com/en-us/azure/app-service/networking/private-endpoint#conceptual-overview) Private Endpoint is only used for incoming flows to your Web App. Outgoing flows will not use this Private Endpoint, but you can inject outgoing flows to your network in a different subnet through the VNet integration feature.
- App Service with regional VNet integration feature to make outbound calls to the Key Vault VNet private endpoint, like [this](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet#private-endpoints). This doesn't grant inbound private access to the app, and thats not part of the scenario.


## Questions

- Is Key Vault Private Link in preview? I think its out of date [docs](https://docs.microsoft.com/en-us/azure/key-vault/general/private-link-service?tabs=portal#create-a-new-key-vault-and-establish-a-private-link-connection) and raised a [ticket](https://github.com/MicrosoftDocs/azure-docs/issues/75212).
- Is this going to work with Managed Identity?
- Key Vaults are generally just in a single region because they have build in redundency. How will the cross region scenario work, like for north europe apps calling west europe key vaults? Docs are saying that there's a *Gateway required VNet integration* approach. Would we have VNets in north and west and [peer](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet#peering) them? Ref. [Regional VNet Integration](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet#regional-vnet-integration)
    - Resources in a VNet in the same region as your app.
    - Resources in VNets peered to the VNet your app is integrated with.
    - Service endpoint secured services.
    - Resources across Azure ExpressRoute connections.
    - Resources in the VNet you're integrated with.
    - Resources across peered connections, which include Azure ExpressRoute connections.
    - Private endpoints <------ This
- Do private endpoints need NSGs? 
- When you use VNet Integration with VNets in the same region, you can use the following Azure networking features. Do we need these? I don't think so.
    - Network security groups (NSGs): You can block outbound traffic with an NSG that's placed on your integration subnet. The inbound rules don't apply because you can't use VNet Integration to provide inbound access to your app.
    - Route tables (UDRs): You can place a route table on the integration subnet to send outbound traffic where you want.
- By default, your app routes only RFC1918 traffic into your VNet. If you want to route all of your outbound traffic into your VNet, use the following steps to add the WEBSITE_VNET_ROUTE_ALL. I don't think this is needed for KV isolation. Could be considered as part of a wider security piece.
- Are the private DNS A records scoped to the VNet only? How does that work with peering? What can go wrong with that? Whats the SLAs on the private links and can we monitor them? Thinking we're taking more responsibility here than just using the Azure domains. We had DNS failures on web endpoints a while back and Akamai / Microsoft couldn't work it out, what what if our config starts failing?
- Ref. [Limitations and Design Considerations](https://docs.microsoft.com/en-us/azure/key-vault/general/private-link-service?tabs=cli#limitations-and-design-considerations), max 64 private endpoints per KV, don't think thats a problem. Default Number of Key Vaults with Private Endpoints per Subscription: 400. What does that mean?

## Setup

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az login

sub=$(az account show --query id -o tsv)
echo $sub

az group create -g $rg -l $loc
echo $rg
```


### [Establish a private link connection to Key Vault using CLI](https://docs.microsoft.com/en-us/azure/key-vault/general/private-link-service?tabs=cli#establish-a-private-link-connection-to-key-vault-using-cli-initial-setup)


```sh
kv=adt-kv-$id
kvep=adt-kvep-$id
vnet=adt-vnet-$id
snet=adt-snet-$id
zlink=adt-zlink-$id
plink=adt-plink-$id

az provider register -n Microsoft.KeyVault
az keyvault create -g $rg -l $loc -n $kv
az keyvault update -g $rg -n $kv --default-action deny

az network vnet create -g $rg -l $loc -n $vnet
az network vnet subnet create -g $rg -n $snet \
    --vnet-name $vnet \
    --address-prefixes 10.0.0.0/26 
az network vnet subnet update -g $rg -n $snet \
    --vnet-name $vnet \
    --disable-private-endpoint-network-policies true
az network private-dns zone create -g $rg -n privatelink.vaultcore.azure.net
az network private-dns link vnet create -g $rg -n $zlink \
    --virtual-network $vnet \
    --zone-name privatelink.vaultcore.azure.net \
    --registration-enabled true
az network private-endpoint create -g $rg -n $kvep -l $loc \
    --vnet-name $vnet \
    --subnet $snet \
    --private-connection-resource-id "/subscriptions/$sub/resourceGroups/$rg/providers/Microsoft.KeyVault/vaults/$kv" \
    --group-ids vault \
    --connection-name $plink

kvepnic=$(az network private-endpoint show -g $rg -n $kvep --query "networkInterfaces[0].id" -o tsv)
kvepnicip=$(az network nic show --ids $kvepnic --query "ipConfigurations[0].privateIpAddress" -o tsv)

az network private-dns zone list -g $rg
az network private-dns record-set a add-record -g $rg -n $kv \
    -z "privatelink.vaultcore.azure.net" \
    -a $kvepnicip
az network private-dns record-set list -g $rg -z "privatelink.vaultcore.azure.net"
```


Test the endpoint is addressable.

```sh
az network vnet subnet create -g $rg -n $snet-test \
    --vnet-name $vnet \
    --address-prefixes 10.0.1.0/24
az vm create -g $rg -n adt-vm-$id -l $loc \
    --image UbuntuLTS \
    --vnet-name $vnet \
    --subnet $snet-test \
    --admin-username azureuser \
    --admin-password <...>
```

Get onto the box and lookup the domains...

```sh
(base) andrew@Andrews-MacBook-Air scenarios % ssh azureuser@40.118.53.10
The authenticity of host '40.118.53.10 (40.118.53.10)' can't be established.
ECDSA key fingerprint is SHA256:lHbpUOrg8p8tA/J4CYUxWYwUWL1bR98ugAWP8zd9qg0.
Are you sure you want to continue connecting (yes/no/[fingerprint])? y
Please type 'yes', 'no' or the fingerprint: yes
Warning: Permanently added '40.118.53.10' (ECDSA) to the list of known hosts.
azureuser@40.118.53.10's password: 
Welcome to Ubuntu 18.04.5 LTS (GNU/Linux 5.4.0-1046-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed May 12 21:26:27 UTC 2021

  System load:  0.1               Processes:           111
  Usage of /:   4.5% of 28.90GB   Users logged in:     0
  Memory usage: 5%                IP address for eth0: 10.0.1.4
  Swap usage:   0%

 * Pure upstream Kubernetes 1.21, smallest, simplest cluster ops!

     https://microk8s.io/





The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

azureuser@adt-vm-21993:~$ $kv
azureuser@adt-vm-21993:~$ nslookup adt-kv-21993.vault.azure.net
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
adt-kv-21993.vault.azure.net	canonical name = adt-kv-21993.privatelink.vaultcore.azure.net.
Name:	adt-kv-21993.privatelink.vaultcore.azure.net
Address: 10.0.0.4

azureuser@adt-vm-21993:~$ nslookup adt-kv-21993.privatelink.vaultcore.azure.net
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	adt-kv-21993.privatelink.vaultcore.azure.net
Address: 10.0.0.4


exit
```

Seems to work! Deallocate the test VM...

```sh
az vm deallocate -g $rg -n adt-vm-$id
```


### Web app VNet integration

```sh
plan=adt-pl-$id
webapp=adt-wa-$id
 
az appservice plan create -g $rg -l $loc -n $plan --sku "S1"
az webapp create -g $rg -p $plan -n $webapp

az network vnet subnet create -g $rg -n $snet-test-app \
    --vnet-name $vnet \
    --address-prefixes 10.0.2.0/24

az webapp vnet-integration add -g $rg -n $webapp --vnet $vnet --subnet $snet-test-app
```

Then at the app service Kudu cmd I did the same lookups and it worked...

```sh
C:\home>nslookup adt-kv-21993.vault.azure.net
Non-authoritative answer:

Server:  UnKnown
Address:  168.63.129.16

Name:    adt-kv-21993.privatelink.vaultcore.azure.net
Address:  10.0.0.4
Aliases:  adt-kv-21993.vault.azure.net


C:\home>nslookup adt-kv-21993.privatelink.vaultcore.azure.net
Non-authoritative answer:

Server:  UnKnown
Address:  168.63.129.16

Name:    adt-kv-21993.privatelink.vaultcore.azure.net
Address:  10.0.0.4

```
