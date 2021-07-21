# Quickstart for encrypting a VM with Azure Disk Encrypt

```sh
az vm create -g $rg -n adt-vm-$id \                                  
    --image win2016datacenter \
    --admin-username vm-admin \
    --admin-password <password-here>

ip=$(az vm show -d  -g $rg -n adt-vm-$id --query "publicIps" -o tsv)

az keyvault create -g $rg -n adt-kv-$id -l $loc --enabled-for-disk-encryption
az vm encryption enable -g $rg -n adt-vm-$id --disk-encryption-keyvault adt-kv-$id

az vm encryption show -g $rg -n adt-vm-$id
```
