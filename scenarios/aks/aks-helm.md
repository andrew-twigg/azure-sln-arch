# Develop on AKS with Helm

Ref. https://docs.microsoft.com/en-us/azure/aks/quickstart-helm

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
acr=adt0acr0$id
aks=adt-aks-$id

az group create -g $rg -l $loc
az acr create -g $rg -n $acr -l $loc --sku Basic
az aks create -g $rg -n $aks -l $loc --attach-acr $acr --generate-ssh-keys

az aks install-cli
az aks get-credentials -g $rg -n $aks
```

Clone an app

```sh
git clone https://github.com/Azure/dev-spaces
cd dev-spaces/samples/nodejs/getting-started/webfrontend
```

Publish the image

```sh
az acr build --image webfrontend:v1 -r $acr --file Dockerfile .
```

Create the helm chart

```sh
helm create webfrontend
```


