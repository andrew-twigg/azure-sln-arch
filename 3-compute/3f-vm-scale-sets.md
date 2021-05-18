# Build a scalable application with virtual machine scale sets

Enable your app to automatically adjust to changes in load while minimising cost with VM scale sets.


## Learning objectives

- Features and capabilities of VM scale sets
- Use cases for running apps on VM scale sets
- Deploy an app on a scale set


## Features and benefits

- Scalable way to run apps on a set of VMs
- All same config and run same apps
- VM count scales with demand
- Ideal for scenarios that include compute workloads, big data, and container


## What is a scale set?

- Allow deployment and management of many load balanced identical VMs
- Vms have same configurations
- Autoscale
- Can also change the size of VM instances
- Uses a load balancer to distribute requests across the VM instances
- Health probes, removes VM from rotation if unhealthy
- Linux/Windows VMs
- Upto 1000 VMs
- Great for unpredictable demand
- Automatically provide HA environment


## Scaling options

- Horizontal
- Vertical
- Scheduled
- Autoscaling, metric-based threshold


## Low priority scale sets

- get compute at upto 80% cost savings
- compute is temporary
- no SLA
- useful for workloads that run with interuptions or when you need large VMs are low cost


## App deployments

Need a mechanism that updates the app consistently across all instances in the scale set.
- Use a custom script extension.
- Use with CLI
- config file defines the files to get and commands to run

```sh
# yourConfigV1.json 
{
  "fileUris": ["https://raw.githubusercontent.com/yourrepo/master/custom_application_v1.sh"],
  "commandToExecute": "./custom_application_v1.sh"
}
```

deploy...

```sh
az vmss extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --resource-group myResourceGroup \
  --vmss-name yourScaleSet \
  --settings @yourConfigV1.json
```

- **Automatic**: doesn't define when the VMs are upgraded. Could all happen at once and cause outage
- **Rolling**: rolls out in batches across the VMs with optional pause can minimise or eliminate service outage. Can run different versions for short time.
- **Manual**: not updates. All changes done manually. Default.

## Create a scale set

```sh
az group create --location westeurope --name $RG

az vmss create \
    --resource-group $RG \
    --name webServerScaleSet \
    --image UbuntuLTS \
    --upgrade-policy-mode automatic \
    --custom-data 3f/cloud-init.yaml \
    --admin-username azureuser \
    --generate-ssh-keys

az network lb probe create \
    --lb-name webServerScaleSetLB \
    --resource-group $RG \
    --name webServerHealth \
    --port 80 \
    --protocol Http \
    --path /

az network lb rule create \
    --resource-group $RG \
    --name webServerLoadBalancerRuleWeb \
    --lb-name webServerScaleSetLB \
    --probe-name webServerHealth \
    --backend-pool-name webServerScaleSetLBBEPool \
    --backend-port 80 \
    --frontend-ip-name loadBalancerFrontEnd \
    --frontend-port 80 \
    --protocol tcp
```

Scale manually

```sh
az vmss scale \
    --name MyVMScaleSet \
    --resource-group $RG \
    --new-capacity 6
```
