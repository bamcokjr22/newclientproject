@description('Name of Virtual Network')
param vnetName string

@description('Location where virtual network will be deployed')
param location string

@description('Address Space of Virtual Network')
param vnetAddressPrefix string

@description('Name of Subnet')
param subnetName string

@description('Subnet address space')
param subnetPrefix string


resource network 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}
