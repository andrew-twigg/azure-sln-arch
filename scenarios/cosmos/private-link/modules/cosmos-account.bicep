@description('Specifies the location for the resources.')
param location string = resourceGroup().location

@description('An environment name prefix for all resources.')
param namePrefix string

@description('An environment name suffix for all resources.')
param nameSuffix string

@description('An array of location objects.')
param locations array

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: '${namePrefix}-cdb-${nameSuffix}'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    publicNetworkAccess: 'Disabled'
  }
}

output cosmosDbAccountId string = cosmosDbAccount.id
output cosmosDbAccountName string = cosmosDbAccount.name
