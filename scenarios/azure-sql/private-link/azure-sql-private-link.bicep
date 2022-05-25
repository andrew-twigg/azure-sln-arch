@description('Specifies the location for the resources of the primary region.')
param location string = resourceGroup().location

@description('The deployment identifier added to the end of resources')
param deploymentId string

param isSecondary bool = false

param sourceDatabaseId string = ''

module vnets 'modules/create-networking/main.bicep' = {
  name: 'vnet-deploy'
  params: {
    namePrefix: 'adt'
    deploymentId: deploymentId
    location: location
    isSecondary: isSecondary
  }
}

module sqlAzure 'modules/create-azure-sql/main.bicep' = {
  name: 'azure-sql-deploy'
  params: {
    sqlNamePrefix: 'adt'
    deploymentId: deploymentId
    adminPassword: 'PAs5w0rd1234'
    location: location
    isReplica: isSecondary
    sourceDatabaseId: sourceDatabaseId
  }
}

output sqlDatabaseId string = sqlAzure.outputs.sqlDatabaseId
