param location string = resourceGroup().location

param namePrefix string
param nameSuffix string
//param deploymentId string

@description('Private link resource type')
param resourceType string

@description('Private link resource name')
param resourceName string

@description('Private link resource group id')
param groupType string

@description('Resource id of the private link subnet')
param subnet string

var privateEndpointName = '${namePrefix}-pep-${nameSuffix}'
var privateEndpointConnectionName = '${namePrefix}-pep-cxn-${nameSuffix}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointConnectionName
        properties: {
          privateLinkServiceId: resourceId(resourceType, resourceName)
          groupIds: [
            groupType
          ]
        }
      }
    ]
    subnet: {
      id: subnet
    }
  }
}
