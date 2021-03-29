# Run Docker containers with Azure Container Instances

Azure Container Instances (ACI) is useful for scenarios that can operate in isolated containers, including simple apps, task automation, and build jobs.

- **Fast startup**
- **Micro billing**
- **Hypervisor-level security** isolates the app as completely as a VM
- **Custom sizes**
- **Persistant storage**
- **Linux and Windows**


## Creating an ACI

```sh
az group create --name learn-deploy-aci-rg --location eastus

DNS_NAME_LABEL=aci-demo-$RANDOM
az container create \
  --resource-group $RG \
  --name mycontainer \
  --image microsoft/aci-helloworld \
  --ports 80 \
  --dns-name-label $DNS_NAME_LABEL \
  --location eastus

az container show \
  --resource-group $RG \
  --name mycontainer \
  --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" \
  --out table

az container logs \
  --resource-group $RG \
  --name mycontainer-restart-demo
```

## Environment Variables

- dynamically configure the app or script the container runs
- secured environment variables enable you to prevent sensitive info from displaying

```sh
COSMOS_DB_NAME=aci-cosmos-db-$RANDOM
COSMOS_DB_ENDPOINT=$(az cosmosdb create \
  --resource-group $RG \
  --name $COSMOS_DB_NAME \
  --query documentEndpoint \
  --output tsv)

COSMOS_DB_MASTERKEY=$(az cosmosdb keys list \
  --resource-group $RG \
  --name $COSMOS_DB_NAME \
  --query primaryMasterKey \
  --output tsv)

az container create \
  --resource-group $RG \
  --name aci-demo \
  --image microsoft/azure-vote-front:cosmosdb \
  --ip-address Public \
  --location eastus \
  --environment-variables \
    COSMOS_DB_ENDPOINT=$COSMOS_DB_ENDPOINT \
    COSMOS_DB_MASTERKEY=$COSMOS_DB_MASTERKEY
```

For secure environment variables use **--secure-environment-variables** flag.


## Data Volumes

Specify the share and volume mount point when creating the ACI.

```sh
az container create \
  --resource-group learn-deploy-aci-rg \
  --name aci-demo-files \
  --image microsoft/aci-hellofiles \
  --location eastus \
  --ports 80 \
  --ip-address Public \
  --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-share-name aci-share-demo \
  --azure-file-volume-mount-path /aci/logs/
```


## Troubleshoot

- Pulling container logs
- Viewing container events
- Attaching to a container instance


### Container Logs

```sh
az container logs \
  --resource-group learn-deploy-aci-rg \
  --name mycontainer
```

You'll see...

```sh
Checking for script in /app/prestart.sh
Running script /app/prestart.sh
Running inside /app/prestart.sh, you could add migrations to this file, e.g.:

#! /usr/bin/env bash

# Let the DB start
sleep 10;
# Run migrations
alembic upgrade head
```


### Container Events

- The *az container attach* command provides diagnostics information during container startup
- Once started, also writes standard output and error streams to local terminal

```sh
az container attach \
  --resource-group learn-deploy-aci-rg \
  --name mycontainer
```

You'll see...

```sh
Container 'mycontainer' is in state 'Running'...
(count: 1) (last timestamp: 2018-09-21 23:48:14+00:00) pulling image "microsoft/sample-aks-helloworld"
(count: 1) (last timestamp: 2018-09-21 23:49:09+00:00) Successfully pulled image "microsoft/sample-aks-helloworld"
(count: 1) (last timestamp: 2018-09-21 23:49:12+00:00) Created container
(count: 1) (last timestamp: 2018-09-21 23:49:13+00:00) Started container

Start streaming logs:
Checking for script in /app/prestart.sh
Running script /app/prestart.sh
```


### Execute a command in a container

To work inside the container...

```sh
az container exec \
  --resource-group learn-deploy-aci-rg \
  --name mycontainer \
  --exec-command /bin/sh
```

Run a command...

```sh
# ls
__pycache__  main.py  prestart.sh  static  templates  uwsgi.ini
```


### Monitor CPU

```sh
az monitor metrics list \
  --resource $CONTAINER_ID \
  --metric CPUUsage \
  --output table
```

Shows you...

```sh
Timestamp            Name              Average
-------------------  ------------  -----------
2018-08-20 21:39:00  CPU Usage
2018-08-20 21:40:00  CPU Usage
2018-08-20 21:41:00  CPU Usage
2018-08-20 21:42:00  CPU Usage
2018-08-20 21:43:00  CPU Usage      0.375
2018-08-20 21:44:00  CPU Usage      0.875
2018-08-20 21:45:00  CPU Usage      1
2018-08-20 21:46:00  CPU Usage      3.625
2018-08-20 21:47:00  CPU Usage      1.5
2018-08-20 21:48:00  CPU Usage      2.75
2018-08-20 21:49:00  CPU Usage      1.625
2018-08-20 21:50:00  CPU Usage      0.625
2018-08-20 21:51:00  CPU Usage      0.5
2018-08-20 21:52:00  CPU Usage      0.5
2018-08-20 21:53:00  CPU Usage      0.5
```

Memory usage...

```sh
az monitor metrics list \
  --resource $CONTAINER_ID \
  --metric MemoryUsage \
  --output table
```
