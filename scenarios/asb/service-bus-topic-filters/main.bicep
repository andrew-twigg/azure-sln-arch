@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('User object ID for the identity of the sample app which needs to manage namespace, send, and receive messages')
param userObjectId string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

// Role definitions to grant to the user.
// Role definition IDs are at https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var serviceBusDataRoleDefinitionIds = [
  '090c5cfd-751d-490a-894a-3ce6f1109419' // Azure Service Bus Data Owner role
  '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39' // Azure Service Bus Data Sender role
  '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0' // Azure Service Bus Data Receiver role
]

// Existing Service Bus Data Roles
resource serviceBusDataRoleDefinitions 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = [for roleId in serviceBusDataRoleDefinitionIds : {
  name: roleId
  scope: serviceBusNamespace
}]

// User role assignment
resource serviceBusNamespaceDataRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for (roleId, i) in serviceBusDataRoleDefinitionIds : {

  // A role assignment's resource name must be a globally unique identifier (GUID). It's a good practice to create a GUID
  // that uses the scope, principal ID, and role ID together. Role assignment resource names must be unique within the
  // Azure Active Directory tenant, even if the scope is narrower.
  name: guid(subscription().id, userObjectId, serviceBusDataRoleDefinitions[i].id)

  // Scope to the service bus namespace.
  // This isn't least privilage. Could be scoped the assignment to the specific queue, but the demo scenario needs owner at the namespace to manage the topics.
  scope: serviceBusNamespace
  properties: {
    roleDefinitionId: serviceBusDataRoleDefinitions[i].id
    principalId: userObjectId
    principalType: 'User'
  }
}]
