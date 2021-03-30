# Deploy and run a containerised web app with Azure App Service

Use Azure App Service to deploy a web app based on a Docker image.

- approach enables quick time to deploy
- support CI/CD


## Container Registry

- Azure service to create private Docker registries
- organised around repos containing one or more images
- automate tasks such as redeploying and app when rebuilt
- security
    - more control over who can see images
    - sign images to increase trust and reduce chances of malicious mods to an image
    - encrypted at rest
- like working with Docker Hub, with benefits
    - runs in Azure
    - images closer to deployment locations
    - highly scalable registry
    - Premium SKU includes 500GiB of storage


```sh
az acr create \
    --name myregistry \
    --resource-group mygroup \
    --sku standard \
    --admin-enabled true

az acr build \
    --file Dockerfile \
    --registry myregistry \
    --image myimage .
```


## Docker image

```sh
git clone https://github.com/MicrosoftDocs/mslearn-deploy-run-container-app-service.git
cd mslearn-deploy-run-container-app-service/dotnet

az acr build \
    --registry $ACR \
    --image webimage .
```


## Deploy web app from ACR

Can deploy directly to App Service from ACR via an option on the app service provisioning.

Continuous deployment allows you to deploy the latest version quickly with the minimum of fuss. Azure App Service supports CD via *web hooks*. An App Service web app can subscribe to an Azure Container Registry webhook to receive notification about updates to the image that contains the web app. When the notification is received, the app automatically restarts the site and pulls the latest version.


### ACR Tasks feature

- rebuilds an image whenever its source code changes, automatically
- monitors a GitHub repo that contains code and triggers a build when changed


### App Service CI

- Container settings page of the App Service resource automates the setup of CI
- App Service configures a webhook in your container registry to notify an App Service endpoint
- Have to create from the command line


```sh
az acr task create \
    --registry <container_registry_name> \
    --name buildwebapp \
    --image webimage \
    --context https://github.com/MicrosoftDocs/mslearn-deploy-run-container-app-service.git \
    --file Dockerfile --git-access-token <access_token>
``` 
