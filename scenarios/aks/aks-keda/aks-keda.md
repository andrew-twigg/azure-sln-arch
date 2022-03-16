# Kubernetes-based Event Driven Autoscaler (KEDA)

## References

* [KEDA](https://keda.sh/)
* [KEDA at Alibaba](https://bit.ly/alibaba-cloud-keda)
* [Azure Functions on Kubernetes with KEDA](https://docs.microsoft.com/en-us/azure/azure-functions/functions-kubernetes-keda)
* [Thinktecture, Serverless workloads in K8s with KEDA](https://www.thinktecture.com/en/kubernetes/serverless-workloads-with-keda/serverless-workloads-with-keda/)

## Why do you want KEDA?

KEDA lets you scale deployments in Kubernetes based on **external** events or metrics.

In Kubernetes, you can use Horizontal Pod Autoscaler (HPA) to scale Deployments based on metrics generated **inside** of the cluster. Especially when running Kubernetes in combination with external, cloud-based services such as Azure Service Bus, your application artifacts have to scale on those external metrics.

## Installing KEDA on Kubernetes

### Create the K8s cluster

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

### Install KEDA

```sh
# add KEDA repo
helm repo add kedacore https://kedacore.github.io/charts

# update the repo
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda
```

### Verify deployment

```sh
kubectl get all -n keda

NAME                                                   READY   STATUS    RESTARTS   AGE
pod/keda-operator-778cf49bcf-vbqdc                     1/1     Running   0          53s
pod/keda-operator-metrics-apiserver-5ccf7b74dd-bt2jp   1/1     Running   0          53s

NAME                                      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
service/keda-operator-metrics-apiserver   ClusterIP   10.0.142.28   <none>        443/TCP,80/TCP   53s

NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/keda-operator                     1/1     1            1           53s
deployment.apps/keda-operator-metrics-apiserver   1/1     1            1           53s

NAME                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/keda-operator-778cf49bcf                     1         1         1       53s
replicaset.apps/keda-operator-metrics-apiserver-5ccf7b74dd   1         1         1       53s
```
