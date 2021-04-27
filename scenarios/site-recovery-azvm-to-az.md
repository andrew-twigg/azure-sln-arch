# Replicate Azure VMs to another Azure region with Azure Site Recovery

## References

- [Tutorial](https://docs.microsoft.com/en-us/azure/site-recovery/azure-to-azure-how-to-enable-replication)
- [Azure VM off-site backups via CLI](https://serverfault.com/questions/1023304/azure-vm-off-site-backups-via-cli)

```sh
RG=adt-rg-$RANDOM
RGBAC=adt-rg-$RANDOM
VAULT=adt-bv-$RANDOM

az group create -g $RG -l westeurope
az group create -g $RGBAC -l northeurope

az vm create \
    -g $RG \
    -n VM1 \
    --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password $PW

az backup vault create \
    -g $RGBAC \
    -n $VAULT \
    -l northeurope
```

[Enable site recovery](https://docs.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication#enable-site-recovery) in the portal. TODO: What are the CLI commands?



```sh
# [Remove protection?](https://docs.microsoft.com/en-us/cli/azure/backup/protection?view=azure-cli-latest)
az backup vault delete -g $RG -n VmBackupVault

```
