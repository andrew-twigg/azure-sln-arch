# Private Link - Connect to a Cosmos DB account

## References

- https://docs.microsoft.com/en-us/azure/private-link/tutorial-private-endpoint-cosmosdb-portal
- [AzureBastion CLI](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/bastion/create-host-cli.md)
- [Azure Cosmos, configure access from Private Endpoints](https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-configure-private-endpoints#adding-private-endpoints-to-an-existing-cosmos-account-with-no-downtime)


## Setup

Create a VNet and a Bastion.

```sh
id=$RANDOM
rg=adt-rg-$id
loc=eastus

az group create -g $rg -l $loc
az network vnet create -g $rg -l $loc -n adt-vnet-$id \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name default \
    --subnet-prefix 10.1.0.0/24

# See link above for Bastion networking requirements (at least /27 and called AzureBastionSubnet)
az network vnet subnet create -g $rg -n AzureBastionSubnet --address-prefixes 10.1.1.0/24 --vnet-name adt-vnet-$id

az network public-ip create -g $rg -l $loc -n adt-pip-$id-bastion --sku Standard
az network bastion create -g $rg -l $loc -n adt-bastion-$id \
    --public-ip-address adt-pip-$id-bastion \
    --vnet-name adt-vnet-$id

az vm create -g $rg -l $loc -n adt-vm-$id --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password Pas5w0rd123456 \
    --vnet-name adt-vnet-$id \
    --subnet default \
    --public-ip-address "" 
```

Create CosmosDB account.

```sh
az cosmosdb create -g $rg -l $loc -n adt-cdb-$id --enable-public-network false
```

Create a private endpoint.

```sh
sub=$(az account show --query id -o tsv)
zone="privatelink.documents.azure.com"

az network vnet subnet update -g $rg -n default \
    --vnet-name adt-vnet-$id \
    --disable-private-endpoint-network-policies true

az network private-endpoint create -g $rg -n adt-privateendpoint-$id \
    --vnet-name adt-vnet-$id \
    --subnet default \
    --private-connection-resource-id "/subscriptions/$sub/resourceGroups/$rg/providers/Microsoft.DocumentDB/databaseAccounts/adt-cdb-$id" \
    --group-id Sql \
    --connection-name adt-privateconnection-$id

az network private-dns zone create -g $rg -n $zone
az network private-dns link vnet create -g $rg -n adt-zlink-$id \
    --zone-name $zone \
    --virtual-network adt-vnet-$id \
    --registration-enabled false
az network private-endpoint dns-zone-group create -g $rg -n adt-zgroup-$id \
    --endpoint-name adt-privateendpoint-$id \
    --private-dns-zone $zone \
    --zone-name adt-zone-$id

```

Add a database and a container.

```sh
az cosmosdb sql database create -g $rg -n mydatabaseid --account-name adt-cdb-$id
az cosmosdb sql container create -g $rg -n mycontainerid \
    --account-name adt-cdb-$id \
    --database-name mydatabaseid \
    --partition-key-path "/mykey"
```

[Test connectivity](https://docs.microsoft.com/en-us/azure/private-link/tutorial-private-endpoint-cosmosdb-portal#test-connectivity-to-private-endpoint)

