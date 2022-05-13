@description('The SQL deployment name prefix in <prefix>-sql-<instance>')
@minLength(1)
@maxLength(3)
param sqlNamePrefix string

@description('The SQL deployment name instance in <prefix>-sql-<instance>')
param sqlNameInstance string

param location string = resourceGroup().location

param adminPassword string

var sqlServerName = '${sqlNamePrefix}-sql-${sqlNameInstance}'
var sqlDatabaseName = '${sqlNamePrefix}-db-${sqlNameInstance}'

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
    sampleName: 'AdventureWorksLT'
  }
}
