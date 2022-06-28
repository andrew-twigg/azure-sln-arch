@description('Specifies the location for the resources.')
param location string = resourceGroup().location

@description('Naming prefix for environment resources.')
param namePrefix string = 'adt'

@description('Naming suffix for environment resources.')
param nameSuffix string

@description('User object ID for the identity of the sample app which needs to send and receive messages.')
param userObjectId string

var captureContainerName = '${namePrefix}-eh-${nameSuffix}-capture'

// The event hub namespace
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: '${namePrefix}-ehns-${nameSuffix}'
  location: location
  properties: {
    minimumTlsVersion: '1.2'
  }
}

// The storage account for capture
resource captureStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${namePrefix}0sa0${nameSuffix}'
  location: location
  sku: {
    name:'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// The storage account container for capture
resource captureContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${captureStorageAccount.name}/default/${captureContainerName}'
}

// The event hub
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: '${namePrefix}-eh-${nameSuffix}'
  parent: eventHubNamespace
  properties: {
    captureDescription: {
      enabled: true
      skipEmptyArchives: false
      encoding: 'Avro'
      intervalInSeconds: 60
      sizeLimitInBytes: 20971520
      destination: {
        name: 'EventHubArchive.AzureBlockBlob'
        properties: {
          storageAccountResourceId: captureStorageAccount.id
          blobContainer: captureContainerName
          archiveNameFormat: '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
        }
      }
    }
  }
}

// Role definitions to grant to the user.
// Role definition IDs are at https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var rbacRoleDefinitionIds = [
  // 'f526a384-b230-433a-b45c-95f59c4a2dec' // Azure Event Hubs Data Owner
  'a638d3c7-ab3a-418d-83e6-5f17a39d4fde' // Azure Event Hubs Data Receiver
  '2b629674-e913-4c01-ae53-ef4638d8f975' // Azure Event Hubs Data Sender
]

// Existing Event Hub Data Roles
resource eventHubDataRoleDefinitions 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = [for roleId in rbacRoleDefinitionIds : {
  name: roleId
  scope: eventHub
}]

// User role assignment
resource eventHubDataRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for (roleId, i) in rbacRoleDefinitionIds : {

  // A role assignment's resource name must be a globally unique identifier (GUID). It's a good practice to create a GUID
  // that uses the scope, principal ID, and role ID together. Role assignment resource names must be unique within the
  // Azure Active Directory tenant, even if the scope is narrower.
  name: guid(subscription().id, userObjectId, eventHubDataRoleDefinitions[i].id)

  // Scope to the event hub.
  scope: eventHub
  properties: {
    roleDefinitionId: eventHubDataRoleDefinitions[i].id
    principalId: userObjectId
    principalType: 'User'
  }
}]

output storageAccountId string = captureStorageAccount.id
output containerName string = captureContainer.name
