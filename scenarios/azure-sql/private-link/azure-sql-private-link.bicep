param location string = resourceGroup().location

module sqlAzure 'modules/create-azure-sql/main.bicep' = {
  name: 'azure-sql-deploy'
  params: {
    sqlNamePrefix: 'adt'
    sqlNameInstance: '01'
    adminPassword: 'PAs5w0rd1234'
    location: location
  }
}
