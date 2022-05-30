# Multi-region web app with private connectivity to database

This example shows a secure and highly available deployment if Azure SQL.

* Multi-region Azure SQL Failover Group
* Hub and spoke virtual networks with the Azure SQL instances exposed in each region via Private Endpoints in the hub networks
* Azure App Service VNet integrated into each regions spoke network
* Azure SQL read/write primary and readonly secondary with auto-failover of the DNS CNAME to save needing to update connection strings.
* Configuration of the Private DNS, adding the SQL Private endpoint records, and adding the VNet links to all VNets across regions.

## References

* [Multi-region web app with private connectivity to database](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/sql-failover/app-service-private-sql-multi-region)
* [Bicep and ARM templates Microsoft.Sql servers](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers?tabs=bicep)
* [Azure quickstart templates web app consuming an Azure SQL private endpoint](https://github.com/Azure/azure-quickstart-templates/tree/master/demos/private-endpoint-sql-from-appservice)
* [Azure SQL active geo-replication and failover](https://docs.microsoft.com/en-us/azure/azure-sql/database/active-geo-replication-configure-portal?view=azuresql&tabs=azure-cli)
* [Web app private link with Azure SQL DB and storage](https://azure.microsoft.com/en-gb/resources/templates/web-app-regional-vnet-private-endpoint-sql-storage/)
* [Web app private connectivity to Azure SQL Database](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/private-web-app/private-web-app#deploy-this-scenario)

## Bicep Setup

```sh
id=$RANDOM

env1=wus
env2=eus

rg1=adt-rg-$id-$env1
rg2=adt-rg-$id-$env2

loc1=westus
loc2=eastus

az group create -g $rg1 -l $loc1
az group create -g $rg2 -l $loc2

az deployment group create -g $rg1 -f azure-sql-private-link.bicep \
    -p  deploymentId=$id \
        envNamePrimary=$env1 \
        envNameSecondary=$env2 \
        sqlAdminPassword=<something>
az deployment group create -g $rg2 -f azure-sql-private-link.bicep \
    -p  isSecondary=true \
        primaryDeploymentResourceGroup=$rg1 \
        deploymentId=$id \
        envNamePrimary=$env1 \
        envNameSecondary=$env2 \
        sqlAdminPassword=<something>
```
