# Canary deployments strategy for Kubernetes deployments

Ref. https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/kubernetes/canary-demo?view=azure-devops&tabs=yaml


## Create a container registry and cluster

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

acr=adt0acr0$id
aks=adt-aks-$id

az acr create -g $rg -n $acr --sku Basic
az aks create -g $rg -n $aks --node-count 1 --enable-addons monitoring --generate-ssh-keys

sudo az aks install-cli
az aks get-credentials -g $rg -n $aks

kubectl get nodes
```

## Install promethius operator, but could use app insights.

Had problems here following the docs. Ref. [stack](https://stackoverflow.com/questions/64226913/install-prometheus-operator-doesnt-work-on-aws-ec2-keeps-produce-error-failed) for the solution. Also, there's lots of deprecation warnings so don't think this is a current approach.

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update

helm install sampleapp stable/prometheus-operator
```

TODO: Got as far as creating the cluster service connection on DevOps and it was sat spinning so gave up.
