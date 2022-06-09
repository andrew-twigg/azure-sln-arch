@description('Private endpoint name.')
param privateEndpointName string

@description('Private DNS Zone Id.')
param privateDnsZoneId string

@description('Private endpoint DNS group name.')
param privateEndpointDnsGroupName string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' existing = {
  name: privateEndpointName
}

resource privateEndpointPrivateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  name: privateEndpointDnsGroupName
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
