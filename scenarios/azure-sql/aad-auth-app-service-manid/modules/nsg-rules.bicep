//param location string = resourceGroup().location

param nsgName string

param securityRules array

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' existing = {
  name: nsgName
}

resource rules 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = [for rule in securityRules: {
  name: rule.name
  parent: nsg
  properties: rule.properties 
}]
