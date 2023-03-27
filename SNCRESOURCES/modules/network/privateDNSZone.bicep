param privateDNSZoneName string
param vnetId string
param registrationEnabled bool

var location = 'global'

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDNSZoneName
  location: location
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDNSZone
  name: '${privateDNSZoneName}-link'
  location: location
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: vnetId
    }
  }
}

// resource aRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   name: '@'
//   parent: privateDNSZone
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: '10.0.0.1'
//       }
//     ]
//     // cnameRecord: {
//     //   cname: 'database'
//     // }
//   }
// }


output dnsZoneId string = privateDNSZone.id
