@description('Specifies the location for the resources.')
param location string = resourceGroup().location

@description('Indicates if the deployment is for a secondary region.')
param isSecondary bool = false

@description('The resource group name of the primary deployment. This is for referencing resources when deploying the secondary.')
param primaryDeploymentResourceGroup string = ''

@description('The deployment identifier of the primary deployment.')
param primaryDeploymentId string = ''

@description('The deployment identifier of the deployment deployment.')
param secondaryDeploymentId string = ''

@description('An environment name prefix for all resources.')
param namePrefix string = 'adt'

@description('The admin password used for Azure SQL.')
@secure()
param sqlAdminPassword string

var deploymentId = isSecondary ? secondaryDeploymentId: primaryDeploymentId

// This is only needed when deploying the secondary region.
var secondaryDeploymentResourceGroup = isSecondary ? resourceGroup().name: ''

var vnetConfigurationSet = {
  Primary: [
    {
      name: '${namePrefix}-vnet-spoke-${primaryDeploymentId}'
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
      peerings: [
        {
          peerTo: '${namePrefix}-vnet-hub-${primaryDeploymentId}'
        }
      ]
      globalPeerings: [
        {
          peerTo: '${namePrefix}-vnet-hub-${secondaryDeploymentId}'
          resourceGroup: secondaryDeploymentResourceGroup
        }
      ]
    }
    {
      name: '${namePrefix}-vnet-hub-${primaryDeploymentId}'
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
      peerings: [
        {
          peerTo: '${namePrefix}-vnet-spoke-${primaryDeploymentId}'
        }
      ]
      globalPeerings: [
        {
          peerTo: '${namePrefix}-vnet-spoke-${secondaryDeploymentId}'
          resourceGroup: secondaryDeploymentResourceGroup
        }
      ]
    }
  ]
  Secondary: [
    {
      name: '${namePrefix}-vnet-spoke-${secondaryDeploymentId}'
      addressPrefix: '10.2.2.0/24'
      subnets: [
        {
          name: 'AppSvcSubnet'
          addressPrefix: '10.2.2.0/25'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          udrName: null
          nsgName: null
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
      peerings: [
        {
          peerTo: '${namePrefix}-vnet-hub-${secondaryDeploymentId}'
        }
      ]
      globalPeerings: [
        {
          peerTo: '${namePrefix}-vnet-hub-${primaryDeploymentId}'
          resourceGroup: primaryDeploymentResourceGroup
        }
      ]
    }
    {
      name: '${namePrefix}-vnet-hub-${secondaryDeploymentId}'
      addressPrefix: '10.2.1.0/24'
      subnets: [ 
        {
          name: 'PrivateLinkSubnet'
          addressPrefix: '10.2.1.0/25'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          udrName: null
          nsgName: null
          delegations: null
        }
      ]
      peerings: [
        {
          peerTo: '${namePrefix}-vnet-spoke-${secondaryDeploymentId}'
        }
      ]
      globalPeerings: [
        {
          peerTo: '${namePrefix}-vnet-spoke-${primaryDeploymentId}'
          resourceGroup: primaryDeploymentResourceGroup
        }
      ]
    }
  ]
}

var environmentVnetConfig = isSecondary ? vnetConfigurationSet.Secondary : vnetConfigurationSet.Primary

// Regional VNet configuration.

module vnets 'modules/vnet.bicep' = [for vnetSettings in environmentVnetConfig : {
  name: 'vnet-deploy-${vnetSettings.name}'
  params: { 
    location: location
    vnetSettings: vnetSettings
  }
}]

// Regional VNet peering configuration.

module vnetPeerings 'modules/vnet-peering.bicep' = [for vnetSettings in environmentVnetConfig : {
  name: 'vnet-peering-deploy-${vnetSettings.name}'
  dependsOn: vnets
  params: {
    vnetSettings: vnetSettings
  }
}]

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

module vnetPeeringsGlobalPrimary 'modules/vnet-peering-global.bicep' = [for vnetSettings in vnetConfigurationSet.Primary : if (isSecondary) {
  name: 'vnet-peering-global-deploy-${vnetSettings.name}'
  dependsOn: vnets
  scope: resourceGroup(primaryDeploymentResourceGroup)
  params: {
    vnetSettings: vnetSettings
  }
}]

module vnetPeeringsGlobalSecondary 'modules/vnet-peering-global.bicep' = [for vnetSettings in vnetConfigurationSet.Secondary : if (isSecondary) {
  name: 'vnet-peering-global-deploy-${vnetSettings.name}'
  dependsOn: vnets
  scope: resourceGroup()
  params: {
    vnetSettings: vnetSettings
  }
}]

// Regional Azure SQL configuration.

module sqlAzure 'modules/azure-sql.bicep' = {
  name: 'azure-sql-deploy'
  params: {
    sqlNamePrefix: 'adt'
    deploymentId: deploymentId
    adminPassword: sqlAdminPassword
    location: location
    isSecondary: isSecondary
    primaryDeploymentResourceGroup: primaryDeploymentResourceGroup
    primaryDeploymentId: primaryDeploymentId
  }
}
