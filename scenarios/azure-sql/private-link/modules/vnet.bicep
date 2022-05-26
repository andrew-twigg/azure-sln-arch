param location string = resourceGroup().location

@description('The settings defining the VNet.')
param vnetSettings object

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetSettings.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetSettings.addressPrefix
      ]
    }
    subnets: [for subnet in vnetSettings.subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        delegations: subnet.delegations
      }
    }]
  }
}

output subnets array = vnet.properties.subnets
