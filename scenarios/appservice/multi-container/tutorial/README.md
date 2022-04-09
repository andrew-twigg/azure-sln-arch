# App Service Multi-container Tutorial

## References

* [Multi-container app](https://docs.microsoft.com/en-us/azure/app-service/tutorial-multi-container-app)

## Azure Resources

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
az group create -g $rg -l $loc

az appservice plan create -g $rg -n adt-sp-$id --sku S1 --is-linux

az webapp create -g $rg -n adt-as-$id \
    --plan adt-sp-$id \
    --multicontainer-config-type compose \
    --multicontainer-config-file docker-compose-wordpress.yml
```

Create a MySQL database. East US because couldn't get it in Europe.

```sh
az mysql server create -g $rg \
    -n adt-sql-$id \
    -l eastus \
    --admin-user adminuser \
    --admin-password My5up3rStr0ngPaSw0rd! \
    --sku-name B_Gen5_1 \
    --version 5.7

az mysql db create -g $rg \
    --server-name adt-sql-$id \
    --name wordpress

az mysql db create -g $rg \
    --server-name adt-sql-$id \
    --name wordpress

az webapp config appsettings set -g $rg \
    -n adt-as-$id \
    --settings WORDPRESS_DB_HOST="adt-sql-$id.mysql.database.azure.com" \
        WORDPRESS_DB_USER="adminuser@adt-sql-$id" \
        WORDPRESS_DB_PASSWORD='My5up3rStr0ngPaSw0rd!' \
        WORDPRESS_DB_NAME="wordpress" \
        MYSQL_SSL_CA="BaltimoreCyberTrustroot.crt.pem"
```
