param vnetName string = 'sncvnet'
param location string = resourceGroup().location
param subnetName string = 'sncsubnet'
param subnetPrefix string = '10.0.0.0/24'
param vnetAddressPrefix string = '10.0.0.0/16'

module virtualNetwork 'network/network.bicep' = {
  name: 'snc-virtualNetwork'
  params: {
    location: location
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    vnetAddressPrefix: vnetAddressPrefix
    vnetName: vnetName
  }
}
