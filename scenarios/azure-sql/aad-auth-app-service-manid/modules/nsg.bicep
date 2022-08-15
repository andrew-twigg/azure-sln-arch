param location string = resourceGroup().location

@description('Network security group name')
param nsgName string

@description('NSG security rules')
param nsgSecurityRules array

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: nsgSecurityRules
  }
}

output networkSecurityGroup string = nsg.id
