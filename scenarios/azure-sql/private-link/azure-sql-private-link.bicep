@description('Specifies the location for the resources.')
param location string = resourceGroup().location

@description('The deployment identifier added to the end of resources')
param deploymentId string

@description('Indicates if the deployment is for a secondary region.')
param isSecondary bool = false

@description('The resource group name of the primary deployment. This is for referencing resources when deploying the secondary.')
param primaryDeploymentResourceGroup string = ''

@description('The deployment identifier of the primary deployment. This is for referencing resources when deploying secondary.')
param primaryDeploymentId string = ''

@description('An environment name prefix for all resources.')
param namePrefix string = 'adt'

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

var environmentVnetConfig = isSecondary ? vnetConfigurationSet.Secondary : vnetConfigurationSet.Primary

module vnets 'modules/create-networking/main.bicep' = [for vnetSettings in environmentVnetConfig : {
  name: 'vnet-deploy-${vnetSettings.name}'
  params: { 
    location: location
    vnetSettings: vnetSettings
  }
}]

module sqlAzure 'modules/create-azure-sql/main.bicep' = {
  name: 'azure-sql-deploy'
  params: {
    sqlNamePrefix: 'adt'
    deploymentId: deploymentId
    adminPassword: 'PAs5w0rd1234'
    location: location
    isSecondary: isSecondary
    primaryDeploymentResourceGroup: primaryDeploymentResourceGroup
    primaryDeploymentId: primaryDeploymentId
  }
}
