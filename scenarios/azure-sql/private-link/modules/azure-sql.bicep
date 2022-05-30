@description('Location to deploy the Azure SQL Db server')
param location string = resourceGroup().location

@description('Azure SQL Db server administrator login name')
param sqlAdministratorLogin string = 'sql-admin'

@description('Azure SQL Db server administrator login password')
@secure()
param sqlAdministratorLoginPassword string

@description('Azure SQL server name')
param sqlServerName string

@description('Azure SQL database name')
param sqlDatabaseName string

@description('Azure SQL database edition')
param databaseEdition string = 'Basic'

@description('Azure SQL database collation type')
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Azure SQL database service objective type name')
param databaseServiceObjectiveName string = 'Basic'

param isSecondary bool = false

param primaryDeploymentResourceGroup string = ''

param primarySqlServerName string

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
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
  properties: isSecondary ? {
    edition: databaseEdition
    collation: databaseCollation
    requestedServiceObjectiveName: databaseServiceObjectiveName
    createMode: 'Secondary'
    sourceDatabaseId: sourceDatabase.id
    secondaryType: 'Geo'
  } : {
    edition: databaseEdition
    collation: databaseCollation
    requestedServiceObjectiveName: databaseServiceObjectiveName
    sampleName: 'AdventureWorksLT'
  }
}

output sqlDatabaseId string = sqlDatabase.id
output sqlServerId string = sqlServer.id
output sqlServerName string = sqlServerName
