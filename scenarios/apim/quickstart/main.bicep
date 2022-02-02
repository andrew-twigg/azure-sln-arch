param aiName string
param apimName string
param apimLocation string
param publisherName string
param publisherEmail string

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimName
  location: apimLocation
  sku: {
    name: 'Developer'
    capacity: 1
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

// APIM Policy
resource apimPolicy 'Microsoft.ApiManagement/service/policies@2021-08-01' = {
  name: '${apim.name}/policy'
  properties:{
    format: 'rawxml'
    value: '<policies><inbound /><backend><forward-request /></backend><outbound /><on-error /></policies>'
  }
}

// App Insights
resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: aiName
  location: '${resourceGroup().location}'
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// APIM App Insights Logger
resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  name: '${apim.name}/${apim.name}-logger'
  properties: {
    resourceId: '${ai.id}'
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: '${ai.properties.InstrumentationKey}'
    }
  }
}

