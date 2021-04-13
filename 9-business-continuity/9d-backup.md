# Protect virtual machines by using Azure Backup

Azure Backup is a service that allows backup of Azure virtual machines, on-prem servers, Azure file shares, and SQL Server or SAP HANA running on Azure VMs, and other application workloads.


## Features and Scenarios

### What is Azure Backup

Uses zero-infrastructure solutions to enable self-service backups and restores, with at-scale management at a lower and predictable cost.

Offers specialised backup solutions for:

- Azure and on-prem VMs
- SQL Server
- SAP HANA running in Azure VMs


Both Backup and Site Recovery aim to make the system more resilient to faults and failures. Goal of Backup is to maintain copies of stateful data that allows you to go back in time, where site recovery replicates the data in almost real time and allows for a failover.

Backups are used in cases of accidental data loss, or corruption, or ransomware attacks. Site recovery is used for a region-wide disaster.


### Why use Azure Backup?

- **Zero-infrastructure** backup eliminates the need to deploy and manage any backup infrastructure or storage. 
    - no overhead in maintaining backup servers
    - no scaling the storage up or down as needs vary
- **Long-term retention** to meet rigorous compliance and audit needs by retaining backups for many years
    - recovery points will be pruned automatically by the built-in lifecycle management
- **Security** provided by Backup to your backup environment when data is in both transit and rest
    - **RBAC**
    - **Encryption of backups** automatically using Microsoft-managed keys, or Key Vault keys
    - **No internet connectivity required**, all data transfer happens on the Azure backbone without needing to cross VNets. No access to any IPs or FQDNs is required
    - **Soft delete** retains backups for 14 additional days
- **High availability** with three types of replication, LRS, GRS, and RA-GRS
- **Centralised monitoring and management**


### Supported scenarios

- **Azure VMs**, linux and Windows, stored in Recovery Services vault with management of recovery points.
- **On-prem** backups of files, folders, and systsem state using Microsoft Azure Recovery Services (MARS) agent, or Microsoft Azure Backup Server (MABS) or Data Protection Manager (DPM) server to protect on-prem VMs and other  on-prem workloads
- **Azure file shares** 
- **SQL Server in Azure VMs and SAP HANA databases in Azure VMs**


## Example

Setup the environment...

```sh
RGROUP=$(az group create --name vmbackups --location westus2 --output tsv --query name)
az network vnet create \
    --resource-group $RGROUP \
    --name NorthwindInternal \
    --address-prefix 10.0.0.0/16 \
    --subnet-name NorthwindInternal1 \
    --subnet-prefix 10.0.0.0/24
az vm create \
    --resource-group $RGROUP \
    --name NW-APP01 \
    --size Standard_DS1_v2 \
    --vnet-name NorthwindInternal \
    --subnet NorthwindInternal1 \
    --image Win2016Datacenter \
    --admin-username admin123 \
    --no-wait \
    --admin-password <password>
az vm create \
    --resource-group $RGROUP \
    --name NW-RHEL01 \
    --size Standard_DS1_v2 \
    --image RedHat:RHEL:7-RAW:latest \
    --authentication-type ssh \
    --generate-ssh-keys \
    --vnet-name NorthwindInternal \
    --subnet NorthwindInternal1
```**

Setup the backup...

```sh
az backup protection enable-for-vm \
    --resource-group vmbackups \
    --vault-name azure-backup \
    --vm NW-APP01 \
    --policy-name DefaultPolicy
az backup job list \
    --resource-group vmbackups \
    --vault-name azure-backup \
    --output table
az backup protection backup-now \
    --resource-group vmbackups \
    --vault-name azure-backup \
    --container-name NW-APP01 \
    --item-name NW-APP01 \
    --retain-until 18-10-2030 \
    --backup-management-type AzureIaasVM
```
