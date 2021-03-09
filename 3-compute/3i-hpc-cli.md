# Run parallel tasks in Azure Batch with Azure CLI

## Learning objectives

- Create an Azure Batch job with CLI
- Run an Azure Batch job with CLI
- Check Batch job status and results with CLI
- Monitor a Batch job with Batch Explorer

## Compute-intensive tasks and parallel workloads

- Requirement for massive computational power
    - financial risk modeling
    - 3D image rendering
    - media transcoding
    - genetic sequence analysis
- Potential for these workloads to be broken down and scaled out as tasks


## The components of Azure Batch

- Azure Batch account, a container for all Batch resources
- Pools of compute nodes (Windows/Linux servers)


## Typical Batch workflow

- Upload data and app files to Azure Storage
- Create Batch pool with nodes (servers)
- Batch service brings nodes online and scheduling tasks for execution onto the nodes
- Query status of nodes and progress of tasks
- Task output pushed to Azure storage

![](assets/3i-azure-batch-workflow.png)


## Design an Azure Batch job to run parallel task

There are different methods of creating Azure Batch solutions
- .NET
- Node.js
- CLI

CLI is agile, fastest way to get started before committing to a scaffolding task.

```sh
az batch account create \
    --name $BA \
    --resource-group $RG \
    --location westeurope

az batch account login \
    --name $BA \
    --resource-group $RG \
    --shared-key-auth

az batch pool create \
    --id mypool \ 
    --vm-size Standard_A1_v2 \
    --target-dedicated-nodes 3 \
    --image canonical:ubuntuserver:16.04-LTS \
    --node-agent-sku-id "batch.node.ubuntu 16.04"

az batch pool show --pool-id mypool --query "allocationState"
"steady"

az batch job create \
 --id myjob \
 --pool-id mypool


for i in {1..10}
for> do
for>    az batch task create \
for>    --task-id mytask$i \
for>    --job-id myjob \
for>    --command-line "/bin/bash -c 'echo \$(printenv | grep \AZ_BATCH_TASK_ID) processed by; echo \$(printenv | grep \AZ_BATCH_NODE_ID)'"
for> done
```

### Monitor

```sh
az batch job create \
 --id myjob2 \
 --pool-id mypool

...

az batch task show \
 --job-id myjob2 \
 --task-id mytask1
```

use [Batch Explorer](https://azure.github.io/BatchExplorer/) for large workloads

![](assets/3i-batch-explorer-nodes.png)
