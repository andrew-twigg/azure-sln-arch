param privateDnsZoneName string

param privateLinkNicIpConfig object

resource privateDnsZonesDnsARecords 'Microsoft.Network/privateDnsZones/A@2020-06-01' = [for fqdn in privateLinkNicIpConfig.properties.privateLinkConnectionProperties.fqdns: {
  name: '${privateDnsZoneName}/${split(fqdn, '.')[0]}'
  properties: {
    aRecords: [
      {
        ipv4Address: privateLinkNicIpConfig.properties.privateIPAddress
      }
    ]
    ttl: 3600
  }
}]
