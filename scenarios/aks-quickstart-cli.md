# AKS quickstart with CLI

[Deploy an AKS cluster with CLI](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough)

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
aks=adt-aks-$id

az group create -g $rg -l $loc
az aks create -g $rg -n $aks \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys
```

Connect to the cluster:

```sh
sudo az aks install-cli
az aks get-credentials -g $rg -n $aks

kubectl get nodes

kubectl apply -f aks-quickstart-cli-manifest.yaml
kubectl get service azure-vote-front --watch

CTRL-C


```
