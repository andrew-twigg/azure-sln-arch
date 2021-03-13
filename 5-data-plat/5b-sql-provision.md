# Provision an Azure SQL database to store application data

## Learning objectives

- Benefits of Azure SQL Database
- Configuration and pricing options
- Create in portal
- Connect via Cloud Shell


## Create

- DTUs
    - Database Transaction Unit
    - combined measure of compute, storage, and IO resources
    - simple, preconfigured purchase option
    - eDTUs, <i>elastic Database Transaction Units</i> allows you to choose one price but allow each database in the pool to consume fewer or greater resources depending on current load.

- vCores
    - Virtual cores
    - give you greater control over the compute and storage resources that you create and pay for
    - compared to DTU, vCore model enabled you to configure resources independently

- Elastic pools
    - relate to eDTUs
    - buy a set of compute and storage resources that are shared among all databases in the pool
    - each DB can use the resources they need within the set limits

- Collation
    - rule that sort and compare data
    - define sorting rules when case sensitivity, accent marks, and other lang characteristics are important    


## Connect

```sh
az configure --defaults group=$RG sql-server=$SQLSVR

# list databases on server
az sql db list | jq '[.[] | {name: .name}]'

[
  {
    "name": "Logistics"
  },
  {
    "name": "master"
  }
]


# get the database details
az sql db show --name Logistics | jq '{name: .name, maxSizeBytes: .maxSizeBytes, status: .status}'

{
  "name": "Logistics",
  "maxSizeBytes": 268435456000,
  "status": "Online"
}
```

Connect to SQL

```sh
az sql db show-connection-string \
    --client sqlcmd \
    --name Logistics

sqlcmd -S tcp:adtsql1303.database.windows.net,1433 -d Logistics -U <username> -P <password> -N -l 30
```
