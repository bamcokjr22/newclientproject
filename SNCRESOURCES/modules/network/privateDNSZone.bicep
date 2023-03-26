param privateDNSZoneName string
param location string

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDNSZoneName
  location: location
}

resource aRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '@'
  parent: privateDNSZone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: '10.0.0.1'
      }
    ]
    cnameRecord: {
      cname: 'database'
    }
  }
}
