# Logic App Single Tenant Bicep Scenario

```sh
$id=Get-Random
$rg="adt-rg-$id"
$loc="westeurope"

az group create -g $rg -l $loc
az deployment group create -g $rg -f main.bicep
```