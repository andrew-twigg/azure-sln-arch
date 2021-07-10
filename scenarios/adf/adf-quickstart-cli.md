# Quickstart: Create an Azure Data Factory using Azure CLI

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope
az group create -g $rg -l $loc

az storage account create -g $rg -l $loc -n adfquickstartstorage
az storage container create -g $rg -n adftutorial \
    --account-name adfquickstartstorage$id \
    --auth-mode key
```

Create some text:

```sh
cat > emp.txt
This is text.
```

Ctrl+D to save.

```sh
az storage blob upload --account-name adfquickstartstorage$id \
    --name input/emp.txt \
    --container-name adftutorial \
    --file emp.txt \
    --auth-mode key
```

Create a data factory:

```sh
az extension add -n datafactory
az extension list-available --query "[?name=='datafactory'].installed" -o tsv

az datafactory create -g $rg --factory-name ADFTutorialFactory$id
```

Create a linked service and datasets:

```sh
cs=$(az storage account show-connection-string -g $rg -n adfquickstartstorage$id --key primary --query "connectionString" -o tsv)

echo "{ \"type\":\"AzureStorage\", \"typeProperties\": { \"connectionString\": { \"type\": \"SecureString\", \"value\": \"$cs\" } } }" >> AzureStorageLinkedService.json

az datafactory linked-service create -g $rg \
    --factory-name ADFTutorialFactory$id \
    --linked-service-name AzureStorageLinkedService \
    --properties @AzureStorageLinkedService.json
```

Create a file InputDataset.json:

```sh
{
    "type": 
        "AzureBlob",
        "linkedServiceName": {
            "type":"LinkedServiceReference",
            "referenceName":"AzureStorageLinkedService"
            },
        "annotations": [],
        "type": "Binary",
        "typeProperties": {
            "location": {
                "type": "AzureBlobStorageLocation",
                "fileName": "emp.txt",
                "folderPath": "input",
                "container": "adftutorial"
        }
    }
}
```

Create an input dataset named InputDataset:

```sh
az datafactory dataset create -g $rg \
    --dataset-name InputDataset \
    --factory-name ADFTutorialFactory$id \
    --properties @InputDataset.json
```

Create a file named OutputDataset.json:

```sh
{
    "type": 
        "AzureBlob",
        "linkedServiceName": {
            "type":"LinkedServiceReference",
            "referenceName":"AzureStorageLinkedService"
            },
        "annotations": [],
        "type": "Binary",
        "typeProperties": {
            "location": {
                "type": "AzureBlobStorageLocation",
                "fileName": "emp.txt",
                "folderPath": "output",
                "container": "adftutorial"
        }
    }
}

Create an output dataset named OutputDataset:

```sh
az datafactory dataset create -g $rg \
    --dataset-name OutputDataset \
    --factory-name ADFTutorialFactory$id \
    --properties @OutputDataset.json
```

Create and run the pipeline. 

Create a pipeline file Adfv2QuickStartPipeline.json:

```sh
{
    "name": "Adfv2QuickStartPipeline",
    "properties": {
        "activities": [
            {
                "name": "CopyFromBlobToBlob",
                "type": "Copy",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                       "source": {
                        "type": "BinarySource",
                        "storeSettings": {
                            "type": "AzureBlobStorageReadSettings",
                            "recursive": true
                        }
                    },
                    "sink": {
                        "type": "BinarySink",
                        "storeSettings": {
                            "type": "AzureBlobStorageWriteSettings"
                        }
                    },
                    "enableStaging": false
                },
                "inputs": [
                    {
                        "referenceName": "InputDataset",
                        "type": "DatasetReference"
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "OutputDataset",
                        "type": "DatasetReference"
                    }
                ]
            }
        ],
        "annotations": []
    }
}
```

Create a pipeline:

```sh
az datafactory pipeline create -g $rg \
    --factory-name ADFTutorialFactory$id \
    --name Adfv2QuickStartPipeline \
    --pipeline @Adfv2QuickStartPipeline.json
```

Run the pipeline:

```sh
az datafactory pipeline create-run -g $rg \
    --name Adfv2QuickStartPipeline \
    --factory-name ADFTutorialFactory$id
```

Use the returned id to check the status:

```sh
az datafactory pipeline-run show -g $rg \
    --factory-name ADFTutorialFactory$id \
    --run-id <id-here>
```


