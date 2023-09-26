metadata name = 'VirtualNetwork Module'
metadata description = 'Module used to create virtual network'

@description('Virtual Network Name')
param vnetName string
@description('Location of virtual Network')
param location string
@description('Address Space of Virtual Network')
param vnetAddressPrefixes array
@description('Subnet Name')
param subnets array

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
      }
    }]   
  } 
  tags: {}
}

output vnetName string = virtualnetwork.name
output subnets array = [for (subnet, i) in subnets: {
  subnetName: virtualnetwork.properties.subnets[i].name
  resourceId: virtualnetwork.properties.subnets[i].id
}]
