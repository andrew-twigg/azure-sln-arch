@description('The settings defining the VNet.')
param vnetSettings object

@description('Indicates if the deployment is for a secondary region.')
param isSecondary bool = false

@description('The settings defining the primary VNet. Used when deploying the secondary.')
param primaryVnetSettings object

@description('The name of the primary resource group. Used when deploying the secondary.')
param primaryDeploymentResourceGroup string = ''

resource hubVnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetSettings.hub.name
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetSettings.spoke.name
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: '${vnetSettings.spoke.name}/peering-to-${vnetSettings.hub.name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}

resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: '${vnetSettings.hub.name}/peering-to-${vnetSettings.spoke.name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
  }
}

// Cross-regional Global VNet peering configuration.
//
// This peers the hub networks of both primary and secondary regions with the spoke networks of the other region.
// This is for app connectivity from spoke VNets to backend services active in a specific region.
// Azure SQL is active read/write in one region, and readonly in secondary region until a failover.
// 
// Only happens when deploying a secondary because assumes the primary has been deployed so can reference existing resources.
//
// Note: Modules are used for global peerings because needs to update resources in a different resource group scope.
//       Modules are needed for this.

resource hubVnetPrimary 'Microsoft.Network/virtualNetworks@2021-08-01' existing = if (isSecondary) {
  name: primaryVnetSettings.hub.name
  scope: resourceGroup(primaryDeploymentResourceGroup)
}

resource spokeVnetPrimary 'Microsoft.Network/virtualNetworks@2021-08-01' existing = if (isSecondary) {
  name: primaryVnetSettings.spoke.name
  scope: resourceGroup(primaryDeploymentResourceGroup)
}

module SpokeSecondaryToHubPrimaryGlobalPeering 'vnet-peering-global.bicep' = if (isSecondary) {
  name: 'vnet-global-peering-deploy-spoke-secondary-hub-primary'
  params: {
    sourceVnetName: spokeVnet.name
    targetVnetName: hubVnetPrimary.name
    targetVnetId: hubVnetPrimary.id 
  }
}

module hubPrimaryToSpokeSecondaryGlobalPeering 'vnet-peering-global.bicep' = if (isSecondary) {
  name: 'vnet-global-peering-deploy-hub-primary-spoke-secondary'
  scope: resourceGroup(primaryDeploymentResourceGroup)
  params: {
    sourceVnetName: hubVnetPrimary.name
    targetVnetName: spokeVnet.name
    targetVnetId: spokeVnet.id 
  }
}

module hubSecondaryToSpokePrimaryGlobalPeering 'vnet-peering-global.bicep' = if (isSecondary) {
  name: 'vnet-global-peering-deploy-hub-secondary-spoke-primary'
  params: {
    sourceVnetName: hubVnet.name
    targetVnetName: spokeVnetPrimary.name
    targetVnetId: spokeVnetPrimary.id 
  }
}

module spokePrimaryToHubSecondaryGlobalPeering 'vnet-peering-global.bicep' = if (isSecondary) {
  name: 'vnet-global-peering-deploy-spoke-primary-hub-secondary'
  scope: resourceGroup(primaryDeploymentResourceGroup)
  params: {
    sourceVnetName: spokeVnetPrimary.name
    targetVnetName: hubVnet.name
    targetVnetId: hubVnet.id 
  }
}
