param rgLocation string = resourceGroup().location

// 1 - Plan 
//    * Microsoft.Web/serverfarms
//    * WorkflowStandard (WS1)
//    * Elastic
// 2 - Storage account
// 3 - Workflows, how are they deployed?
//    * Does it need a logic app resource to deploy workflows to?
//    * Or do we just deploy workflows to the plan?
// 4 - App Insights

var logicAppName = 'adt-la-samplebicep'
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
  location: rgLocation
  sku:{
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource myLogicAppStandard 'Microsoft.Web/sites@2021-02-01' = {
  name: logicAppName
  location: rgLocation
  kind: 'functionapp,workflowapp'
  properties: {
    serverFarmId: myPlan.id
    siteConfig:{
      appSettings: [
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~12'
        }
      ]
    }
  }
}
