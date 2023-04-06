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

param dnsServer string

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
    dhcpOptions: {
      dnsServers: [
        dnsServer
      ]
    }
    subnets: [ for (subnet,i) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        networkSecurityGroup: (subnet.associateNSG == false) ? null : {
          id: networkSecurityGroup[i].id
        }
        routeTable: (subnet.associateNSG == false) ? null : {
          id: routeTableId
        }
        delegations: (subnet.delegation == false) ? [] : [
          {
            name: subnet.delegationName
            properties: {
              serviceName: subnet.delegationServiceName
            }
          }
        ]
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


