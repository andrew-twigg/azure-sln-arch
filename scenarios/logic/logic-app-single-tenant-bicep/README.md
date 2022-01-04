# Logic App Single Tenant Bicep Scenario

This is a simple Logic App Standard deployment scenario to demonstrate how to use bicep to deploy the main components.

```sh
$id=Get-Random
$rg="adt-rg-$id"
$loc="westeurope"

az group create -g $rg -l $loc
az deployment group create -g $rg -f main.bicep
```