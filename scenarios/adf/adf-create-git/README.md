# Create an empty data factory with GitHub connections

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc
az deployment group create -g $rg \
    -f azuredeploy.json \
    -p azuredeploy.parameters.json factoryName=adt-adf-$id
```
