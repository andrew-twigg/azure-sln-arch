# ARM template deployment of IPs using resource group locations

Ref. https://www.examtopics.com/exams/microsoft/az-303/view/2/

Answer for location is obvious but, does the name have to be unique? 

```sh
az group deployment create -g $rg-1 -f arm-ip-address-location.json -p name=IP1 location=westus
az group deployment create -g $rg-1 -f arm-ip-address-location.json -p name=IP2 location=westus
az group deployment create -g $rg-2 -f arm-ip-address-location.json -p name=IP1 location=westus
az group deployment create -g $rg-2 -f arm-ip-address-location.json -p name=IP3 location=westus
```

Generates 4 IPs. Names do not need to be unique.
