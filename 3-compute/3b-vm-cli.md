# Manage virtual machines with Azure CLI

```sh
az vm create \
  --resource-group $RG \
  --location westus \
  --name SampleVM \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys \
  --verbose


{
  "fqdns": "",
  "id": "/subscriptions/71aba40f-344e-4bd7-a059-43c86f7d6d1d/resourceGroups/learn-74b191a1-3a47-4d41-aa98-7c3b8e001e5d/providers/Microsoft.Compute/virtualMachines/SampleVM",
  "location": "westus",
  "macAddress": "00-0D-3A-35-C0-AC",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "104.40.5.144",
  "resourceGroup": "learn-74b191a1-3a47-4d41-aa98-7c3b8e001e5d",
  "zones": ""
}
```

list images

```sh
az vm image list --output table
az vm image list --sku <SKU> --output table
az vm image list --location <location> --output table
```

list sizes

```sh
az vm list-sizes --location <location> --output <table>
```

resize

```sh
az vm list-vm-resize-options \
    --resource-group $RG \
    --name SampleVM \
    --output table

az vm resize \
    --resource-group $RG \
    --name SampleVM \
    --size Standard_D2s_v3
```


## JMESPath Queries

[jmespath.org](https://jmespath.org) and [tutorial](https://jmespath.org/tutorial.html)

```sh
az vm show \
    --resource-group $RG \
    --name SampleVM \
    --query "osProfile.adminUsername"

az vm show \
    --resource-group $RG \
    --name SampleVM \
    --query hardwareProfile.vmSize

az vm show \
    --resource-group $RG \
    --name SampleVM \
    --query "networkProfile.networkInterfaces[].id"

az vm get-instance-view \
    --name SampleVM \
    --resource-group $RG \
    --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" -o tsv

az vm open-port \
    --port 80 \
    --resource-group $RG \
    --name SampleVM
```
