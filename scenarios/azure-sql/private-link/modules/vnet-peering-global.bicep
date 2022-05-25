param sourceVnetName string

param targetVnetName string

param targetVnetId string

resource globalPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: '${sourceVnetName}/global-peering-to-${targetVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: targetVnetId
    }
  }
}
