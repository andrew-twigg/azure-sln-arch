param rgLocation string = resourceGroup().location

// 1 - Plan 
//    * Microsoft.Web/serverfarms
//    * WorkflowStandard (WS1)
//    * Elastic
// 2 - Storage account
// 3 - Workflows, how are they deployed?
//    * Does it need a logic app resource to deploy workflows to?
//    * Or do we just deploy workflows to the plan?

var logicAppPlanName = 'adt-plan-samplebicep'
var logicAppStorageName = 'adt0sa0samplebicep'

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?tabs=bicep
resource myPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: logicAppPlanName 
  location: rgLocation
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
    size: 'WS1'
    family: 'WS'
    capacity: 1
  }
  kind: 'elastic'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: true
    maximumElasticWorkerCount: 20
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource myStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: logicAppStorageName
  location:rgLocation
  sku:{
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
