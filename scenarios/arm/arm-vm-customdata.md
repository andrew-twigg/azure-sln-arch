# Formatting and mounting a data drive with ARM template and Cloud-init

```sh
id=$RANDOM
rg=adt-rg-$id
echo $rg

az group create -g $rg -l westeurope
az deployment group create -g $rg -n $rg-deployment -f azuredeploy.json -p azuredeploy.parameters.json
```
