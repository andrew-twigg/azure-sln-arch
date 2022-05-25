@description('The SQL deployment name prefix in <prefix>-sql-<deployment-id>')
@minLength(1)
@maxLength(3)
param sqlNamePrefix string

@description('The deployment identifier added to the end of resources')
param deploymentId string

param location string = resourceGroup().location

param adminPassword string

param isSecondary bool = false

param primaryDeploymentResourceGroup string = ''
param primaryDeploymentId string = ''

var sqlServerName = '${sqlNamePrefix}-sql-${deploymentId}'
var sqlDatabaseName = '${sqlNamePrefix}-db-awlt'

var primarySqlServerName = '${sqlNamePrefix}-sql-${primaryDeploymentId}'

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

// If deploying secondary region (SQL replica) then get the primary source SQL database.
resource sourceSqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = if (isSecondary) {
  name: primarySqlServerName
  scope: resourceGroup(primaryDeploymentResourceGroup)
}
resource sourceDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' existing = if (isSecondary) {
  name: sqlDatabaseName
  parent: sourceSqlServer
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
  properties: isSecondary ? {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600 
    createMode: 'Secondary'
    sourceDatabaseId: sourceDatabase.id
    secondaryType: 'Geo'
  } : {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
    sampleName: 'AdventureWorksLT'
  }
}
