@description('The SQL deployment name prefix in <prefix>-sql-<deployment-id>')
@minLength(1)
@maxLength(3)
param sqlNamePrefix string

@description('The deployment identifier added to the end of resources')
param deploymentId string

param location string = resourceGroup().location

param adminPassword string

param isReplica bool = false

param sourceDatabaseId string = ''

var sqlServerName = '${sqlNamePrefix}-sql-${deploymentId}'
var sqlDatabaseName = '${sqlNamePrefix}-db-awlt'

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    administratorLogin: 'sql-admin'
    administratorLoginPassword: adminPassword
    version: '12.0'
    // publicNetworkAccess: 'Disabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: sqlDatabaseName
  location: location
  parent: sqlServer
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
    sampleName: !isReplica ? 'AdventureWorksLT': null
    createMode: isReplica ? 'Secondary': 'Default'
    sourceDatabaseId: isReplica ? sourceDatabaseId : null
    secondaryType: isReplica ? 'Geo' : null
  }
}

output sqlDatabaseId string = sqlDatabase.id
