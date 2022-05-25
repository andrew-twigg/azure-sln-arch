//@description('The deployment name prefix for resources, example <prefix>-vnet-<deployment-id>')
//@minLength(1)
//@maxLength(3)
//param namePrefix string

//@description('The deployment identifier added to the end of resources')
//param deploymentId string

param location string = resourceGroup().location

//param isSecondary bool = false

@description('The settings defining the VNet.')
param vnetSettings object

//var vnetConfig = isSecondary ? vnetConfigurationSet.Secondary : vnetConfigurationSet.Primary

resource vnets 'Microsoft.Network/virtualNetworks@2021-08-01' = {
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
