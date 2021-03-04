# Monitor and troubleshoot end-to-end Azure network infrastructure by using network monitoring tools

Network Watcher tools, diagnostics, and logs to help find and fix networking issues in Azure infrastructure.


## Learning objectives

- Tools available to manage and troubleshoot network connectivity in Azure
- Tool selection to manage and troubleshoot network connectivity for various use cases


## References

- [Azure Network Watcher](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-monitoring-overview)


## What is Network Watcher?

Diagnostics for health of Azure networks.

- Monitoring tools
- Diagnostics

Centralized hub for identifying network glitches, CPU spikes, connectivity problems, memory leaks, and other issues before they effect the business.


## Monitoring tools

- Topology
    - Generates a GUI of the vnet, resourcesm interconnections, and relationships
- Connection Monitor
    - Check that connections work between Azure resources
    - Measures latency between resources
    - Catch changes that will affect connectivity (config/NSG rules)
    - Probe VMs for health / changes
- Network Performance Monitor
    - Track and alert on latency and packet drops over time
    - Centralized view of the network
    - Endpoint-to-endpoint connectivity monitoring:
        - between branches and datacenters
        - between vnets
        - between on-prem and cloud
        - ExpressRoute circuits


## Network Watcher diagnostic tools

- IP flow verify
    - analysis of packets allowed / denied for a specific VM
    - 5-tuple packet parameter-based verification mechanism for detection
    - specify the network adapter and the five tuple
- Next hop
    - traceroute?
- Effective security rules
    - displays all the effective NSG rules applied to a network interface
    - also spot holes in VMs
- Packet capture
    - records all the packets sent to and from a VM
    - VM extension remotely started through Network Watcher
    - Max 100 sessions per region, max 10,000 global
    - Needs <i>Network Watcher Agent VM Extension</i> installed on the VM
- Connection troubleshoot
    - TCP connectivity troubleshooting
- VPN troubleshoot
    - Gateway connection diagnostics


# Exercise

```sh
az network vnet create \
    --resource-group $RG \
    --name MyVNet1 \
    --address-prefix 10.10.0.0/16 \
    --subnet-name FrontendSubnet \
    --subnet-prefix 10.10.1.0/24

az network vnet subnet create \
    --address-prefixes 10.10.2.0/24 \
    --name BackendSubnet \
    --resource-group $RG \
    --vnet-name MYVNet1

az vm create \
    --resource-group $RG \
    --name FrontendVM \
    --vnet-name MyVNet1 \
    --subnet FrontendSubnet \
    --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password <password>

# Install the watcher extension
az vm extension set \
    --publisher Microsoft.Compute \
    --name CustomScriptExtension \ 
    --vm-name FrontendVM \
    --resource-group $RG \
    --settings '{"commandToExecute":"powershell.exe Install-WindowsFeature -Name Web-Server"}' \
    --no-wait

az vm create \
    --resource-group $RG \
    --name BackendVM \
    --vnet-name MyVNet1 \
    --subnet BackendSubnet \
    --image Win2019Datacenter \ 
    --admin-username azureuser \
    --admin-password <password>

az vm extension set \
    --publisher Microsoft.Compute \
    --name CustomScriptExtension \
    --vm-name BackendVM \ 
    --resource-group $RG \
    --settings '{"commandToExecute":"powershell.exe Install-WindowsFeature -Name Web-Server"}' \
    --no-wait

az network nsg create \
    --name MyNsg \
    --resource-group $RG

az network nsg rule create \
    --resource-group $RG \
    --name MyNSGRule \
    --nsg-name MyNsg \
    --priority 4096 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 443 3389 \
    --access Deny \
    --protocol TCP \
    --direction Inbound \
    --description "Deny from specific IP address ranges on 80, 443 and 3389."

az network vnet subnet update \
    --resource-group $RG \
    --name BackendSubnet \
    --vnet-name MyVNet1 \
    --network-security-group MyNsg

az network watcher configure \
    --locations westeurope \
    --enabled true \
    --resource-group $RG
```
