# Azure Batch quickstart

Ref. [Quickstart: Run your first Batch job with the Azure CLI](https://docs.microsoft.com/en-us/azure/batch/quick-create-cli)

- Create a Batch account
- Create a pool of compute nodes (VMs)
- Create a job that runs taks on the pool

Each samples task runs a basic command on one of the pool nodes.

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
sa=adt0sa0$id

az group create -g $rg -l $loc
```

Create a storage account to link to the Batch acc. Useful stage location.

```d
az storage account create -g $rg -l $loc -n $sa --sku Standard_LRS
```

Create a Batch account.

```sh
ba=adt0ba0$id

az batch account create -g $rg -l $loc -n $ba --storage-account $sa
az batch account login -g $rg -n $ba --shared-key-auth
az batch pool create --id mypool \
    --vm-size Standard_A1_v2 \
    --target-dedicated-nodes 2 \
    --image canonical:ubuntuserver:16.04-LTS \
    --node-agent-sku-id "batch.node.ubuntu 16.04"
az batch pool show --pool-id mypool --query "allocationState"
az batch job create --id myjob --pool-id mypool

```

Create tasks.

```sh
for i in {1..4}
do
   az batch task create \
    --task-id mytask$i \
    --job-id myjob \
    --command-line "/bin/bash -c 'printenv | grep AZ_BATCH; sleep 90s'"
done

az batch task show --job-id myjob --task-id mytask1
az batch task file list --job-id myjob --task-id mytask1 -o table
az batch task file download --job-id myjob --task-id mytask1 --file-path stdout.txt --destination ./stdout.txt
```

