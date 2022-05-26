@description('The settings defining the VNet.')
param vnetSettings object

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetSettings.name
}

resource peerToVnets 'Microsoft.Network/virtualNetworks@2021-08-01' existing = [for peering in vnetSettings.peerings : {
  name: peering.peerTo
}]

resource peerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = [for (peering, i) in vnetSettings.peerings: {
  name: '${vnet.name}/peering-to-${peerToVnets[i].name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: peerToVnets[i].id
    }
  }
}]
