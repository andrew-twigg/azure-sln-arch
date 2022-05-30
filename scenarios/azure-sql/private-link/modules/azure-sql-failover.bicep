
param azureSqlFailoverGroupName string
param azureSqlServerPrimaryName string
param azureSqlServerSecondaryId string
param databaseName string

resource sqlPrimary 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  name: azureSqlServerPrimaryName
}

resource sqlFailoverGroup 'Microsoft.Sql/servers/failoverGroups@2021-11-01-preview' = {
  name: azureSqlFailoverGroupName
  parent: sqlPrimary
  properties:{
    readWriteEndpoint: {
      failoverPolicy: 'Automatic'
      failoverWithDataLossGracePeriodMinutes: 60
    }
    partnerServers: [
      {
        id: azureSqlServerSecondaryId
      }
    ]
    databases: [
      resourceId('Microsoft.Sql/servers/databases', azureSqlServerPrimaryName, databaseName)
    ]
  }
}
