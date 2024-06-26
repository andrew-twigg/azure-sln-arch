# Build a containerized web application with Docker

- Containerization saves time and reduces costs
- Don't have to configure hardware and spend time installing OS / SW to host deployment
- Multiple apps run in isolated containers on the same hardware
- Scale out quickly by starting additional container instances
- Container images are an extensible base


## Learning objectives

- Create a Dockerfile for a new container image based on a starter image from Docker Hub
- Add files to an image using Dockerfile commands
- Configure an image's startup command with Dockerfile commands
- Build and run a web application packaged in a Docker image
- Deploy a Docker image using the Azure Container Instance service


## Retrieve an existing Docker image and deploy it locally

- Deploy apps and service quickly and easily
- Runs using a Docker image
- Docker image is a prepackaged environment containing the application code and the environment in which it executes
    - typically much smaller footprint than an equiv. VM
    - docker container doesn't have the overhead of the entire OS
- Docker does not provide the level of isolation available with VMs
    - VMs isolate at the hardware level
    - it does ensure that containers cannot access resources of another unless configured


### Docker registries and Docker Hub

- Docker images are stored and made available in *registries*
- A registry is organised as a series or *repositories*
    - contains multiple Docker images
    - share a common name
    - generally the same purpose and functionality
    - different versions identified with a tag
    - repository is the unit of privacy for an image


### Containers and files

- Changes made to running container only exist in the container where changes were made, and are volatile
- Multiple containers bsed on the same image that run simultaneously do not share the files in the image
    - data written by one container to it filesystem are not visible to others
- Writable volumes
    - file system that can be mounted by the container
    - made available to the app running in a container
    - data is not volatile
    - multiple containers can share the data


### Customise a Docker image

- *layer* your app on top of a base image
- apps meant to be packaged as docker images typically have a Dockerfile located in the root of the source code and almost always named Dockerfile.

```Dockerfile
FROM mcr.microsoft.com/dotnet/core/sdk:2.2
WORKDIR /app
COPY myapp_code .
RUN dotnet build -c Release -o /rel
EXPOSE 80
WORKDIR /rel
ENTRYPOINT ["dotnet", "myapp.dll"]
```

```sh
docker build -t myapp:v1 .
```


## ACR

```sh
az acr create \
    --name myregistry \
    --resource-group $RG \
    --sku standard \
    --admin-enabled true
```

To connect...

```sh
docker login <registry-name>.azurecr.io
az acr credential show --name <registry-name>
```

For pushing...

- create an alias for the image and tag it
- repo name in format *<login_server>/<image_name>:<tag/>*, using *docker tag*

```sh
docker tag myapp:v1 myregistry.azurecr.io/myapp:v1
docker push myregistry.azurecr.io/myapp:v1
```

Verify the upload...

```sh
# list repositories in the registry
az acr repository list --name myregistry

# list the images in the registry
az acr repository show --repository myapp --name myregistry
```

> **Note**
>
> You'll see at least two tags for each image in a repository. One tag will be a value you specified in the *acr build* command. The other will be *latest*. Every time you rebuild an image, ACR automatically creates the *latest* tag as an alias for the most recent version of the image.


Run with ACI...

```sh
az container create \
    --resource-group mygroup \
    --name myinstance \
    --image myregistry.azurecr.io/myapp:latest \
    --dns-name-label mydnsname \
    --registry-username <username> \
    --registry-password <password>

az container show \
    --resource-group mygroup \
    --name myinstance \
    --query ipAddress.fqdn
```
