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

var vnetConfigurationSet = {
  Primary: {
    spoke: {
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
    }
    hub: {
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
    }
  }
  Secondary: {
    spoke: {
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
    }
    hub: {
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
    }
  }
}

var environmentVnetConfig = isSecondary ? vnetConfigurationSet.Secondary : vnetConfigurationSet.Primary

module vnets 'modules/vnet.bicep' = [for vnetSettings in items(environmentVnetConfig) : {
  name: 'vnet-deploy-${vnetSettings.value.name}'
  params: { 
    location: location
    vnetSettings: vnetSettings.value
  }
}]

module vnetPeering 'modules/vnet-peering.bicep' = {
  name: 'vnet-peering-deploy'
  params: {
    vnetSettings: environmentVnetConfig
    isSecondary: isSecondary
    primaryDeploymentResourceGroup: primaryDeploymentResourceGroup
    primaryVnetSettings: vnetConfigurationSet.Primary
  }
}

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
