# Build and deploy to Azure Kubernetes Service

Ref. https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/kubernetes/aks-template?view=azure-devops


### Create a container registry

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

acr=adt0acr0$id
aks=adt-aks-$id

az acr create -g $rg -n $acr --sku Basic
az aks create -g $rg -n $aks \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys


```
