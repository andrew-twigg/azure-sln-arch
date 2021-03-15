# Migrate your relational data stored in SQL Server to Azure SQL Database

Azure Database Migration Service automates database migration tasks to Azure SQL Database.


- Migration strategy for relational data stored in SQL Server
- Process of migration downtime

https://raw.githubusercontent.com/MicrosoftDocs/mslearn-migrate-sql-server-relational-data/master/azuredeploy.json



```sh
wget https://raw.githubusercontent.com/MicrosoftDocs/mslearn-migrate-sql-server-relational-data/master/azuredeploy.json

RG=adt-5d-rg
DEPLOYMENT=adt-5d-$RANDOM

az group create \
    --name $RG \
    --location westeurope

az deployment group create \
--name $DEPLOYMENT \
--resource-group $RG \
--template-uri https://raw.githubusercontent.com/MicrosoftDocs/mslearn-migrate-sql-server-relational-data/master/azuredeploy.json
--parameters \
    sourceWindowsAdminUserName windowsadmin \
    sourceWindowsAdminPassword 1N54rty&&^123 \
    sourceSqlAdminUserName sqladmin \
    sourceSqlAdminPassword 456gfrsw@£$ \
    targetSqlDbAdministratorLogin azuresqladmin \
    targetSqlDbAdministratorPassword fgh*&^54rty

