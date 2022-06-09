@description('Private dns zone name')
param privateDnsZoneName string

@description('Private endpoint nic ip configuration array')
param privateLinkNicIpConfigs array

module dnsRecords 'dns-record.bicep' = [for (ipConfig, i) in privateLinkNicIpConfigs: {
  name: 'private-link-ipconfigs-dns-${i}'
  params: {
    privateDnsZoneName: privateDnsZoneName
    privateLinkNicIpConfig: ipConfig
  }
}] 
