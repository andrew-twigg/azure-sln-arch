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

// Networking Configuration Set
// https://docs.microsoft.com/bs-latn-ba/azure/azure-resource-manager/bicep/patterns-configuration-set
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

module sql 'modules/azure-sql.bicep' = {
  name: 'azure-sql-deploy'
  params: {
    location: location
    sqlAdministratorLoginPassword: sqlAdminPassword
    sqlServerName: '${namePrefix}-sql-${deploymentId}'
    sqlDatabaseName: '${namePrefix}-db-awlt'
    isSecondary: isSecondary
    primaryDeploymentResourceGroup: primaryDeploymentResourceGroup
    primarySqlServerName: '${namePrefix}-sql-${primaryDeploymentId}'
  }
}

module sqlPrivateLink 'modules/private-link.bicep' = {
  name: 'azure-sql-private-link-deploy'
  params: {
    location: location
    namePrefix: namePrefix
    nameSuffix: '${deploymentId}-sql'
    resourceType: 'Microsoft.Sql/servers'
    resourceName: sql.outputs.sqlServerName
    groupType: 'sqlServer'

    // Hub VNet, Private Link subnet
    // Don't like this indexing, but wanting to use the output to avoid 'dependsOn'
    subnet: vnets[1].outputs.subnets[0].id 
  }
}

var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

// Create the private DNS zone in the primary only.
// The secondary VNets will link to this global resource.
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (!isSecondary) {
  name: privateDnsZoneName
  location: 'global'
}

// Link virtual networks of the resource group we're deploying to the Private DNS Zone in the primary.
module privateDnsZoneLinks 'modules/private-dns-link.bicep' = [for (vnetSettings, i) in environmentVnetConfig: {
  name: 'private-dns-link-deploy-${vnetSettings.Name}'
  scope: resourceGroup(primaryDeploymentResourceGroup)
  params: {
    privateDnsZoneName: privateDnsZone.name
    virtualNetworkName: vnets[i].outputs.vnetName
    virtualNetworkResourceGroup: resourceGroup().name
  }
}]

// Create the DNS records for the SQL private link.
// TODO: Why do we need this? There are already DNS records provided by the Private endpoint, ex. adt-sql-19020-eus.database.windows.net.
//       Is it because the DNS records of the Private endpoint don't bridge the peerings?
module sqlPrivateLinkIpConfigs 'modules/private-link-ipconfigs.bicep' = {
  name: 'azure-sql-private-link-ip-configs-deploy'
  scope: resourceGroup(primaryDeploymentResourceGroup)
  params: {
    privateDnsZoneName: privateDnsZone.name
    privateLinkNic: sqlPrivateLink.outputs.privateLinkNic
  }
}

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'app-service-plan-deploy'
  params: {
    location: location
    namePrefix: namePrefix
    nameSuffix: deploymentId
  }
}

module appService 'modules/app.bicep' = {
  name: 'app-service-deploy'
  params: {
    location: location
    appName: '${namePrefix}-app-${deploymentId}-myapp'
    serverFarm: appServicePlan.outputs.serverFarmId

    // Spoke VNet
    subnet: vnets[0].outputs.subnets[0].id
  }
}
