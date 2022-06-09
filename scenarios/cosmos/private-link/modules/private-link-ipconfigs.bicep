@description('Private dns zone name')
param privateDnsZoneName string

@description('Private endpoint Nic resource id')
param privateLinkNic string

// The module is required because bicep needs an array parameter for the ip configs.
module privateLinkNicIpConfigsDns 'private-link-ipconfigs-dns.bicep' = {
  name: 'private-link-ipconfigs'
  params: {
    privateDnsZoneName: privateDnsZoneName
    privateLinkNicIpConfigs: reference(privateLinkNic, '2021-08-01').ipConfigurations
  }
}
