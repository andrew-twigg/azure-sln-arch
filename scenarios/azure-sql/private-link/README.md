# Multi-region web app with private connectivity to database

This example scenario discusses a highly available solution for a web app with private connectivity to a SQL database.

## References

* [Multi-region web app with private connectivity to database](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/sql-failover/app-service-private-sql-multi-region)
* [Bicep and ARM templates Microsoft.Sql servers](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers?tabs=bicep)
* [Azure quickstart templates web app consuming an Azure SQL private endpoint](https://github.com/Azure/azure-quickstart-templates/tree/master/demos/private-endpoint-sql-from-appservice)

## Setup

```sh
id1=$RANDOM
id2=$RANDOM

rg1=adt-rg-$id1
rg2=adt-rg-$id2

loc1=westus
loc2=eastus

sql1=adt-sql-$id1
sql2=adt-sql-$id2

az group create -g $rg1 -l $loc1
az group create -g $rg2 -l $loc2

az sql server create -l $loc1 -g $rg1 -n $sql1 -u sql-admin -p 'Pas5w0rd1234'
az sql db create -g $rg1 -s $sql1 -n adt-db-$id1 --sample-name 'AdventureWorksLT'

az sql server create -l $loc2 -g $rg2 -n $sql2 -u sql-admin -p 'Pas5w0rd1234'
az sql db replica create -g $rg1 \
    -s $sql1 \
    -n adt-db-$id1 \
    --partner-resource-group $rg2 \
    --partner-server $sql2 \
    --family Gen5 \
    --capacity 2 \
    --secondary-type Geo
```
