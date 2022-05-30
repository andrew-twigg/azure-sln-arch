@description('Location to deploy the Azure SQL Db server')
param location string = resourceGroup().location

@description('App Service Plan SKU')
param serverFarmSku object = {
  Tier: 'Standard'
  Name: 'S1'
}

@description('An environment name prefix for all resources.')
param namePrefix string

@description('An environment name suffix for all resources.')
param nameSuffix string

var serverFarmName = '${namePrefix}-asp-${nameSuffix}'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: serverFarmName
  location: location
  sku: serverFarmSku
  kind: 'app' 
}

//output serverFarmName string = serverFarmName
output serverFarmId string = appServicePlan.id
