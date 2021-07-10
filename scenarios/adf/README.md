# Azure Data Factory v2 Samples

## Setup

Each sample is deployable using an ARM template. Common setup steps:

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc
az deployment group create -g $rg \
    -f azuredeploy.json \
    -p name=adt-adf-$id
```
