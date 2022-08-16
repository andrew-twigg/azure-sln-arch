@description('Specifies the location for the resources.')
param location string = resourceGroup().location

@description('Indicates if the deployment is for a secondary region.')
param isSecondary bool = false

@description('The resource group name of the primary deployment. This is for referencing resources when deploying the secondary.')
param primaryDeploymentResourceGroup string = ''

@description('Deployment id to make this deployment unique. Same across all regions.')
param deploymentId string

@description('Environment name for primary environment.')
param envNamePrimary string

@description('Environment name for secondary environment.')
param envNameSecondary string

@description('An environment name prefix for all resources.')
param namePrefix string = 'adt'

@description('The admin password used for Azure SQL.')
@secure()
param sqlAdminPassword string

var primaryNameSuffix = '${deploymentId}-${envNamePrimary}'
var secondaryNameSuffix = '${deploymentId}-${envNameSecondary}'

var nameSuffix = isSecondary ? secondaryNameSuffix : primaryNameSuffix

// This is only needed when deploying the secondary region.
var secondaryDeploymentResourceGroup = isSecondary ? resourceGroup().name : ''

// Networking Configuration Set
// https://docs.microsoft.com/bs-latn-ba/azure/azure-resource-manager/bicep/patterns-configuration-set
var vnetConfigurationSet = {
  Primary: [
    {
      name: '${namePrefix}-vnet-spoke-${primaryNameSuffix}'
      addressPrefix: '10.1.2.0/24'
      subnets: [
        {
          name: '${namePrefix}-sub-spoke-${primaryNameSuffix}-app'
          addressPrefix: '10.1.2.0/25'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          udrName: null
          nsgName: '${namePrefix}-nsg-spoke-${primaryNameSuffix}-app'
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
          peerTo: '${namePrefix}-vnet-hub-${primaryNameSuffix}'
        }
      ]
      globalPeerings: [
        {
          peerTo: '${namePrefix}-vnet-hub-${secondaryNameSuffix}'
          resourceGroup: secondaryDeploymentResourceGroup
        }
      ]
    }
    {
      name: '${namePrefix}-vnet-hub-${primaryNameSuffix}'
      addressPrefix: '10.1.1.0/24'
      subnets: [
        {
          name: '${namePrefix}-sub-hub-${primaryNameSuffix}-privatelink'
          addressPrefix: '10.1.1.0/25'
          // Public preview of NSGs on Private Endpoints
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          udrName: null
          nsgName: '${namePrefix}-nsg-hub-${primaryNameSuffix}-privatelink'
          delegations: null
        }
      ]
      peerings: [
        {
          peerTo: '${namePrefix}-vnet-spoke-${primaryNameSuffix}'
        }
      ]
      globalPeerings: [
        {
          peerTo: '${namePrefix}-vnet-spoke-${secondaryNameSuffix}'
          resourceGroup: secondaryDeploymentResourceGroup
        }
      ]
    }
  ]
  Secondary: [
    {
      name: '${namePrefix}-vnet-spoke-${secondaryNameSuffix}'
      addressPrefix: '10.2.2.0/24'
      subnets: [
        {
          name: '${namePrefix}-sub-spoke-${secondaryNameSuffix}-app'
          addressPrefix: '10.2.2.0/25'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          udrName: null
          nsgName: '${namePrefix}-nsg-spoke-${secondaryNameSuffix}-app'
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
          peerTo: '${namePrefix}-vnet-hub-${secondaryNameSuffix}'
        }
      ]
      globalPeerings: [
        {
          peerTo: '${namePrefix}-vnet-hub-${primaryNameSuffix}'
          resourceGroup: primaryDeploymentResourceGroup
        }
      ]
    }
    {
      name: '${namePrefix}-vnet-hub-${secondaryNameSuffix}'
      addressPrefix: '10.2.1.0/24'
      subnets: [
        {
          name: '${namePrefix}-sub-hub-${secondaryNameSuffix}-privatelink'
          addressPrefix: '10.2.1.0/25'
          // Public preview of NSGs on Private Endpoints
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          udrName: null
          nsgName: '${namePrefix}-nsg-hub-${secondaryNameSuffix}-privatelink'
          delegations: null
        }
      ]
      peerings: [
        {
          peerTo: '${namePrefix}-vnet-spoke-${secondaryNameSuffix}'
        }
      ]
      globalPeerings: [
        {
          peerTo: '${namePrefix}-vnet-spoke-${primaryNameSuffix}'
          resourceGroup: primaryDeploymentResourceGroup
        }
      ]
    }
  ]
}

var environmentVnetConfig = isSecondary ? vnetConfigurationSet.Secondary : vnetConfigurationSet.Primary

// Regional VNet configuration.

module vnets 'modules/vnet.bicep' = [for vnetSettings in environmentVnetConfig: {
  name: 'vnet-deploy-${vnetSettings.name}'
  params: {
    location: location
    vnetSettings: vnetSettings
  }
}]

// Regional VNet peering configuration.

module vnetPeerings 'modules/vnet-peering.bicep' = [for vnetSettings in environmentVnetConfig: {
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

module vnetPeeringsGlobalPrimary 'modules/vnet-peering-global.bicep' = [for vnetSettings in vnetConfigurationSet.Primary: if (isSecondary) {
  name: 'vnet-peering-global-deploy-${vnetSettings.name}'
  dependsOn: vnets
  scope: resourceGroup(primaryDeploymentResourceGroup)
  params: {
    vnetSettings: vnetSettings
  }
}]

module vnetPeeringsGlobalSecondary 'modules/vnet-peering-global.bicep' = [for vnetSettings in vnetConfigurationSet.Secondary: if (isSecondary) {
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
    sqlServerName: '${namePrefix}-sql-${nameSuffix}'
    sqlDatabaseName: '${namePrefix}-db-${deploymentId}'
    isSecondary: isSecondary
    primaryDeploymentResourceGroup: primaryDeploymentResourceGroup
    primarySqlServerName: '${namePrefix}-sql-${primaryNameSuffix}'
  }
}

module sqlPrivateLink 'modules/private-link.bicep' = {
  name: 'azure-sql-private-link-deploy'
  params: {
    location: location
    namePrefix: namePrefix
    nameSuffix: '${nameSuffix}-sql'
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
module sqlPrivateLinkIpConfigs 'modules/private-link-ipconfigs.bicep' = {
  name: 'azure-sql-private-link-ip-configs-deploy'
  scope: resourceGroup(primaryDeploymentResourceGroup)
  params: {
    privateDnsZoneName: privateDnsZone.name
    privateLinkNic: sqlPrivateLink.outputs.privateLinkNic
  }
}

// TODO: This is the NSG rules to only allow the SQL traffic from the App subnet.
//       Needs to be completed because the private link nic needs to be referenced inside a module. Also needs to work across regions.
//
//module nsgRuleHubPrivateEndpoint 'modules/nsg-rules.bicep' = {
//  name: 'nsg-rules-hub-vnet-private-endpoint-subnet'
////  dependsOn: vnets
//  params: {
//    nsgName: environmentVnetConfig[1].subnets[0].nsgName // vnets[1].outputs.subnets[0].networkSecurityGroup.id
//    securityRules: [
//      {
//        name: 'AllowSpokeVnetAppSubnetInBound'
//        properties: {
//          protocol: 'Tcp'
//          sourcePortRange: '*'
//          destinationPortRange: '1433'
//          sourceAddressPrefix: vnets[1].outputs.subnets[0].properties.addressPrefix
//          destinationAddressPrefix: reference(sqlPrivateLink.outputs.privateLinkNic, '2021-08-01').ipConfigurations
//          access: 'Deny'
//          priority: 1000
//          direction: 'Inbound'
//        }
//      }
//      {
//        name: 'DenyVnetInBound'
//        properties: {
//          protocol: '*'
//          sourcePortRange: '*'
//          destinationPortRange: '*'
//          sourceAddressPrefix: 'VirtualNetwork'
//          destinationAddressPrefix: 'VirtualNetwork'
//          access: 'Deny'
//          priority: 1000
//          direction: 'Inbound'
//        }
//      }
//    ]
//  }
//}

module sqlFailoverGroup 'modules/azure-sql-failover.bicep' = if (isSecondary) {
  name: 'azure-sql-failover-group'
  scope: resourceGroup(primaryDeploymentResourceGroup)
  params: {
    azureSqlFailoverGroupName: '${namePrefix}-sql-${deploymentId}'
    azureSqlServerPrimaryName: '${namePrefix}-sql-${primaryNameSuffix}'
    azureSqlServerSecondaryId: sql.outputs.sqlServerId
    databaseName: '${namePrefix}-db-${deploymentId}'
  }
}

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'app-service-plan-deploy'
  params: {
    location: location
    namePrefix: namePrefix
    nameSuffix: nameSuffix
  }
}

module appService 'modules/app.bicep' = {
  name: 'app-service-deploy'
  params: {
    location: location
    appName: '${namePrefix}-app-${nameSuffix}-myapp'
    serverFarm: appServicePlan.outputs.serverFarmId

    // Spoke VNet
    subnet: vnets[0].outputs.subnets[0].id
  }
}
