@description('Name of Virtual Network')
param vnetName string

@description('Location where virtual network will be deployed')
param location string

@description('Address Space of Virtual Network')
param vnetAddressPrefix string

@description('List of Subnets')
param subnets array

param routeTableId string
// @description('Subnet address space')
// param subnetPrefixes array

param nsgs object

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-06-01' = [for nsg in nsgs.nsgs: {
  name: nsg.name
  location: location
  properties: {
    securityRules: [for rule in nsg.rules: {
      name: rule.name
      properties: rule.properties
    }]
  }
}]

resource network 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [ for (subnet,i) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        networkSecurityGroup: subnet.name == 'appgwSubnet' ? null : {
          id: networkSecurityGroup[i].id
        }
        routeTable: subnet.name == 'appgwSubnet' ? null : {
          id: routeTableId
        }
      }
    }]
  }
}

output vnetName string = network.name

output vnetId string = network.id

output subnet array = [for (subnet, i) in subnets: {
  subnets: network.properties.subnets[i].name
}]

output subnetId array = [for (subnet, i) in subnets: {
  subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnet.name)
}]


