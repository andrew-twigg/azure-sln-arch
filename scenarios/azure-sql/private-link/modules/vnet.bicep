param location string = resourceGroup().location

@description('The settings defining the VNet.')
param vnetSettings object

resource nsgs 'Microsoft.Network/networkSecurityGroups@2021-08-01' = [for subnet in vnetSettings.subnets: {
  name: subnet.nsgName
  location: location
}]

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetSettings.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetSettings.addressPrefix
      ]
    }
    subnets: [for (subnet, i) in vnetSettings.subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        delegations: subnet.delegations
        networkSecurityGroup: {
          id: nsgs[i].id
        }
      }
    }]
  }
}

output vnetName string = vnet.name
output subnets array = vnet.properties.subnets
