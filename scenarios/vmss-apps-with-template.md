# Install apps in a Virtual Machine Scale Set with template

Ref. https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/tutorial-install-apps-template

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

az deployment group create -g $rg \
    --template-uri https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/scale_sets/azuredeploy.json

ip=$(az network public-ip show -g $rg -n myscalesetpublicip --query "[ipAddress]" -o tsv)
curl http://$ip
```

Test result...

```sh
Hello World from host myscaleset000002 !
```
