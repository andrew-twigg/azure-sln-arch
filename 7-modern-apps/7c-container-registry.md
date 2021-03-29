# Build and store container images with Azure Container Registry

Azure Container Registry (ACR) is a managed Docker registry service based on the open-source Docker Registry 2.0.

- private
- hosted on Azure
- build, store and manage instances for all types of container deployments
- geo-replication feature (premium sku)
- build container images in Azure without the need for local Docker tooling (ACR Tasks)


## Create an ACR

```sh
az acr create --resource-group $RG --name $ACR_NAME --sku Premium
```


## Azure Container Registry Tasks

ACR Tasks lets you build containers. Also supports DevOps process integration with automated build on source commit.

```sh
# build the image
az acr build --registry $ACR_NAME --image helloacrtasks:v1 .

# verify
az acr repository list --name $ACR_NAME --output table
```


## Registry authentication

Doesn't support unauthenticated access. Two options:

1. Azure Active Directory identities
    - both user and service principals
    - RBAC with one of three roles
        - reader (pull only)
        - contributor (push and pull)
        - owner (pull, push, assign roles to other users)
2. admin account
    - disabled by default
    - disable this account and use only AAD identities


```sh
az acr update -n $ACR_NAME --admin-enabled true
az acr credential show --name $ACR_NAME

az container create \
    --resource-group learn-deploy-acr-rg \
    --name acr-tasks \
    --image $ACR_NAME.azurecr.io/helloacrtasks:v1 \
    --registry-login-server $ACR_NAME.azurecr.io \
    --ip-address Public \
    --location <location> \
    --registry-username [username] \
    --registry-password [password]

az container show \
    --resource-group  learn-deploy-acr-rg \
    --name acr-tasks \
    --query ipAddress.ip \
    --output table
```


## Container replication to different Azure regions

Geo-replication enables an ACR to function as a single registry serving several regions with multi-master regional registries

- network-close operations
- enabling fast
- reliable image layer transfers
- single registry/image/tag names can be used across regions
- no additional egress fees, as images are pulled from local replicated registry in same region as container host
- single-management across regions


```sh
# replicate to another region
az acr replication create --registry $ACR_NAME --location japaneast
```
