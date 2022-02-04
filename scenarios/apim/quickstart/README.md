# API Management Quickstart

This walkthrough just shows a simple dev setup using Bicep taken from [this](https://medium.com/geekculture/creating-a-azure-api-management-instance-using-bicep-lang-via-azure-devops-873d05998e01) blog.


## References

* [Bicep templates, APIM, Service API Operations](https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/operations?tabs=bicep)
* [rawxml vs xml in ARM templates](https://stackoverflow.com/questions/70278751/what-is-the-difference-between-xml-and-rawxml-formats-when-defining-apim-pol)
* [xml-link](https://stackoverflow.com/questions/48845321/arm-template-api-management-deploy-policycontent)


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

