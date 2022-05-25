@description('The deployment name prefix for resources, example <prefix>-vnet-<deployment-id>')
@minLength(1)
@maxLength(3)
param namePrefix string

@description('The deployment identifier added to the end of resources')
param deploymentId string

param location string = resourceGroup().location

param isSecondary bool = false

var vnetConfigurationSet = {
  Primary: [
    {
      name: '${namePrefix}-vnet-spoke-${deploymentId}'
      addressPrefix: '10.1.2.0/24'
      subnets: [
        {
          name: 'AppSvcSubnet'
          addressPrefix: '10.1.2.0/25'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'appservice'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        } 
      ]
    }
    {
      name: '${namePrefix}-vnet-hub-${deploymentId}'
      addressPrefix: '10.1.1.0/24'
      subnets: [ 
        {
          name: 'PrivateLinkSubnet'
          addressPrefix: '10.1.1.0/25'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: null
        }
      ]
    }
  ]
  Secondary: [
    {
      name: '${namePrefix}-vnet-spoke-${deploymentId}'
      addressPrefix: '10.2.2.0/24'
      subnets: [
        {
          name: 'AppSvcSubnet'
          addressPrefix: '10.2.2.0/25'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'appservice'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        } 
      ]
    }
    {
      name: '${namePrefix}-vnet-hub-${deploymentId}'
      addressPrefix: '10.2.1.0/24'
      subnets: [ 
        {
          name: 'PrivateLinkSubnet'
          addressPrefix: '10.2.1.0/25'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: null
        }
      ]
    }
  ]
}

var vnetConfig = isSecondary ? vnetConfigurationSet.Secondary : vnetConfigurationSet.Primary

resource vnets 'Microsoft.Network/virtualNetworks@2021-08-01' = [for vnet in vnetConfig : {
  name: vnet.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet.addressPrefix
      ]
    }
    subnets: [for subnet in vnet.subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        delegations: subnet.delegations
      }
    }]
  }
}]
