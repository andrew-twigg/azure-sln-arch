@description('The private dns zone name')
param privateDnsZoneName string

@description('The virtual network name')
param virtualNetworkName string

@description('The resource group that the virtual network is in')
param virtualNetworkResourceGroup string

@description('Controls whether the dns zone will automatically register DNS records for resources in the virtual network')
param enableVmRegistration bool = false

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZoneName}-${virtualNetworkName}-link'
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: enableVmRegistration
    virtualNetwork: {
      id: resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
    }
  }
}
