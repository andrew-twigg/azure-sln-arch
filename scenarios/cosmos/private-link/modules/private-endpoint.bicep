@description('Specifies the location for the resources.')
param location string = resourceGroup().location

@description('An environment name prefix for all resources.')
param namePrefix string

@description('An environment name suffix for all resources.')
param nameSuffix string

//@description('Private link resource type')
//param resourceType string

//@description('Private link resource name')
//param resourceName string

@description('Private link service resource id')
param resourceId string

@description('Private link service resource group id')
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
          //privateLinkServiceId: resourceId(resourceType, resourceName)
          privateLinkServiceId: resourceId
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

output privateEndpointName string = privateEndpoint.name
output privateLinkNic string = privateEndpoint.properties.networkInterfaces[0].id
