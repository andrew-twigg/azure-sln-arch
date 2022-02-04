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

// APIM Product
resource apimProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: '${apim.name}/custom-product'
  properties: {
    approvalRequired: true
    subscriptionRequired: true
    displayName: 'Custom product'
    state: 'published'
  }
}

// Add custom policy to the product
resource apimProductPolicy 'Microsoft.ApiManagement/service/products/policies@2021-08-01' = {
  name: '${apimProduct.name}/policy'
  properties: {
    format: 'rawxml'
    value: '<policies><inbound><base /></inbound><backend><base /></backend><outbound><set-header name="Server" exists-action="delete" /><set-header name="X-Powered-By" exists-action="delete" /><set-header name="X-AspNet-Version" exists-action="delete" /><base /></outbound><on-error><base /></on-error></policies>'
  }
}

// Add User
resource apimUser 'Microsoft.ApiManagement/service/users@2021-08-01' = {
  name: '${apim.name}/custom-user'
  properties: {
    firstName: 'Custom'
    lastName: 'User'
    state: 'active'
    email: 'custom-user-email@address.com'
  }
}

// Add Subscription
resource apimSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-08-01' = {
  name: '${apim.name}/custom-subscription'
  properties: {
    displayName: 'Custom Subscription'
    primaryKey: 'custom-primary-key-${uniqueString(resourceGroup().id)}'
    secondaryKey: 'custom-secondary-key-${uniqueString(resourceGroup().id)}'
    state: 'active'
    scope: '/products/${apimProduct.id}'
  }
}

// TODO: Add API and operations
// TODO: Add API definitions to XML files
// TODO: Upload to storage account
// TODO: Reference the link in deployment
