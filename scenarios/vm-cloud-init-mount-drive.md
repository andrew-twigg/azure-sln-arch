# Create a VM with Azure CLI and mount a data drive

- [Create a swap partion](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cloudinit-configure-swapfile) - this is where the approach came from
- [Cloud init, disk setup](https://cloudinit.readthedocs.io/en/latest/topics/examples.html#disk-setup)
 
Approach creates a disk, and then a VM, and uses a custom-data script to prep and mount the disk.

TODO: looks like this is the correct approach but its failing to mount. There's an error in the log *DataSourceAzure.py[DEBUG]: Marker "/var/lib/cloud/instance/sem/config_disk_setup" for module "disk_setup" did not exist*.

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

az disk create -g $rg -n adt-disk-$id --size-gb 10
diskid=$(az disk list -g $rg --query "[?name=='adt-disk-$id'].id" -o tsv)

az vm create -g $rg -n adt-vm-$id \
    --image UbuntuLTS \
    --attach-data-disks $diskid \
    --admin-username azureuser \
    --admin-password Pas5w0rd123456 \
    --custom-data vm-cloud-init-mount-drive-cloud-init.yml
```
