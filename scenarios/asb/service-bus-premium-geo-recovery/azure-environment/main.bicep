@description('Name of the Service Bus namespace')
param serviceBusNamespaceNamePrimary string

@description('Name of the Service Bus namespace')
param serviceBusNamespaceNameSecondary string

@description('Name of Geo-Recovery Configuration Alias')
param aliasName string

@description('Location of the primary namespace')
param locationPrimaryNamespace string = resourceGroup().location

@description('Location of the secondary namespace')
param locationSecondaryNamespace string

// Note: Microsoft.ServiceBus/namespaces API version
// 2021-11-01 is not supported in the regions yet at time of writing 15th Jan 2022.

// Service Bus Namespace (Secondary)
resource serviceBusNamespaceSecondary 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: serviceBusNamespaceNameSecondary
  location: locationSecondaryNamespace
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  properties: {
    zoneRedundant: true
  }
}

// Service Bus Namespace (Primary)
resource serviceBusNamespacePrimary 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: serviceBusNamespaceNamePrimary
  location: locationPrimaryNamespace
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  properties: {
    zoneRedundant: true
  }
}

// Service Bus Namespace Geo-Recovery Config
// This pairs the primary and secondary namespaces
resource serviceBusNamespaceDrConfig 'Microsoft.ServiceBus/namespaces/disasterRecoveryConfigs@2021-06-01-preview' = {
  name: aliasName
  parent: serviceBusNamespacePrimary
  properties: {
    partnerNamespace: serviceBusNamespaceSecondary.id
  }
}
