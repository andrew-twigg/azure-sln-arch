# Create an ingress controller in AKS

Ref. https://docs.microsoft.com/en-us/azure/aks/ingress-basic

## Prereqs

- [Setup AKS with Helm](./aks-helm.md)

## Ingress Controller

```sh
# Create a namespace for ingress resources
kubectl create namespace ingress-basic

# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux

# Check status
kubectl --namespace ingress-basic get services -o wide -w nginx-ingress-ingress-nginx-controller
```

Run the demo apps...

```sh
kubectl apply -f aks-ingress-controller-app-one.yaml --namespace ingress-basic
kubectl apply -f aks-ingress-controller-app-two.yaml --namespace ingress-basic
```

Create the ingress resource...

```sh
kubectl apply -f aks-ingress-controller-app-ingress.yaml --namespace ingress-basic
```

Can now test the app routes.
