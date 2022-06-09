@description('Location to deploy the Azure SQL Db server')
param location string = resourceGroup().location

@description('Name of app service web app (must be globally unique)')
param appName string

@description('Resource id of subnet to use for app service reginal vnet integration')
param subnet string

param serverFarm string

resource app 'Microsoft.Web/sites@2021-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: serverFarm
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          // Where's this come from?
          // It's not in the docs https://docs.microsoft.com/en-us/azure/app-service/overview-vnet-integration#azure-dns-private-zones
          value: '168.63.129.16'
        }
      ]
    }
  }
}

resource appVnetIntegration 'Microsoft.Web/sites/networkConfig@2021-03-01' = {
  parent: app
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnet
    swiftSupported: true
  }
}
