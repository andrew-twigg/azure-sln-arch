# Log network traffic to and from a VM

## Create resource group

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc
```

## Create VM

```sh
az network vnet create -g $rg -n adt-vnet-$id \
    --address-prefix 10.1.0.0/16 \
    --subnet-name Apps \
    --subnet-prefix 10.1.1.0/24 \
    -l $loc

az vm create -g $rg -n adt-vm-$id \
    -l $loc \
    --vnet-name adt-vnet-$id \
    --subnet Apps \
    --image "Win2019Datacenter" \
    --admin-username vm-admin \
    --admin-password "<some-password>"
```

## Enable Network Watcher

TODO: I could not get this to register.

```sh
az storage account create -g $rg -n "adt0sa0$id" -l $loc

az provider register --namespace Microsoft.Insights

az network watcher flow-log create -g $rg -n "adt-fl-$id" \
    --enabled true \
    --nsg "adt-vm-$idNSG" \
    --storage-account "adt0sa0$id" \
    --location $loc
```
