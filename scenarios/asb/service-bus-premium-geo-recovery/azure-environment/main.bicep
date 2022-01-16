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

@description('User object ID for the identity of the sample app which needs to send and receive messages')
param userObjectId string

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

// Service Bus Queue to run the sample app through.
resource serviceBusNamespaceQueue 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview' = {
  name: 'myqueue'
  parent: serviceBusNamespacePrimary
}

// The built in Azure Service Bus Data Sender role.
// Role definition IDs are at https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
resource serviceBusDataSenderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: serviceBusNamespacePrimary
  name: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
}

// The built in Azure Service Bus Data Sender role.
// Role definition IDs are at https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
resource serviceBusDataReceiverRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: serviceBusNamespacePrimary
  name: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
}

resource serviceBusNamespaceQueueDataSenderRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  // A role assignment's resource name must be a globally unique identifier (GUID). It's a good practice to create a GUID 
  // that uses the scope, principal ID, and role ID together. Role assignment resource names must be unique within the 
  // Azure Active Directory tenant, even if the scope is narrower.
  name: guid(subscription().id, userObjectId, serviceBusDataSenderRoleDefinition.id)

  // Scope the assignment to the specific queue
  scope: serviceBusNamespaceQueue
  properties: {
    roleDefinitionId: serviceBusDataSenderRoleDefinition.id
    principalId: userObjectId
    principalType: 'User'
  }  
}

resource serviceBusNamespaceQueueDataReceiverRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  // A role assignment's resource name must be a globally unique identifier (GUID). It's a good practice to create a GUID 
  // that uses the scope, principal ID, and role ID together. Role assignment resource names must be unique within the 
  // Azure Active Directory tenant, even if the scope is narrower.
  name: guid(subscription().id, userObjectId, serviceBusDataReceiverRoleDefinition.id)

  // Scope the assignment to the specific queue
  scope: serviceBusNamespaceQueue
  properties: {
    roleDefinitionId: serviceBusDataReceiverRoleDefinition.id
    principalId: userObjectId
    principalType: 'User'
  }  
}
