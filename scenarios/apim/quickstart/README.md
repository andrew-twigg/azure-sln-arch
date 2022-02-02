# API Management Quickstart

This walkthrough just shows a simple dev setup using Bicep taken from [this](https://medium.com/geekculture/creating-a-azure-api-management-instance-using-bicep-lang-via-azure-devops-873d05998e01) blog.


## Creating the environments

```sh
az deployment group create -g $rg \
    -f main.bicep \
    -p aiName=adt-ai-$id \
        apimName=adt-apim-$id \
        apimLocation=westeurope \
        publisherName=andrew \
        publisherEmail=andrew.twigg@outlook.com
```

