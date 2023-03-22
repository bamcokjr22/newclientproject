targetScope = 'subscription'

param vnetName string = 'sncvnet'
param vnetName2 string = 'sncvnet2'
// param location string = 'CentralUS'
// param subnetName array = ['sncsubnet', 'apimSubnet']
// param subnetPrefix array = ['10.0.0.0/24', '10.0.1.0/24']
param vnetAddressPrefix string = '10.0.0.0/16'
param vnetAddressPrefix2 string = '192.168.0.0/16'
param keyvaultSKUName string = 'standard'
param keyvaultName string = 'snckeyva123456'
param managedIdentityName string = 'ucmanagedid'
param workspaceName string = 'sncaisdatabricks'

var managedResourceGroupName = 'databricks-rgs-${workspaceName}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'snckv-rg'
  location: variables.location
}


// param variables object = loadJsonContent('parameter.json')
param nsgs object = loadJsonContent('parameter.json')

var variables = loadJsonContent('parameter.json')

module routeTable 'modules/network/userdefinedroute.bicep' = {
  scope: resourceGroup
  name: 'sncroutetable'
  params: {
    location: variables.location
    routeTableAddressPrefix: variables.routeTableAddressPrefix
    routeTableName: variables.routeTableName
    routeName: variables.routeName
    routeTableNextHopIPAddress: variables.routeTableNextHopIPAddress
    routeTableNextHopType: variables.routeTableNextHopType
  }
}

module virtualNetwork './modules/network/network.bicep' = {
  scope: resourceGroup
  name: vnetName
  params: {
    location: variables.location
    subnets: variables.subnets
    // subnetPrefixes: variables.subnets.subnetPrefix
    vnetAddressPrefix: vnetAddressPrefix
    vnetName: vnetName
    nsgs: nsgs
    routeTableId: routeTable.outputs.routeTableId
  }
}

module virtualNetwork2 './modules/network/network.bicep' = {
  scope: resourceGroup
  name: vnetName2
  params: {
    location: variables.location
    subnets: variables.subnets2
    // subnetPrefixes: variables.subnets.subnetPrefix
    vnetAddressPrefix: vnetAddressPrefix2
    vnetName: vnetName2
    nsgs: nsgs
    routeTableId: routeTable.outputs.routeTableId
  }
}

module vnetpeering1 'modules/network/vnetpeering.bicep' = {
  scope: resourceGroup
  name: 'sncvnetpeering1'
  params: {
    remoteVirtualNetworkId: virtualNetwork2.outputs.vnetId
    vnetName: virtualNetwork.outputs.vnetName
    remoteVnetName: virtualNetwork2.outputs.vnetName
    allowForwardedTraffic: false
    allowGatewayTransit: false
    allowVirtualNetworkAccess: false
    useRemoteGateways: false
  }
}

module vnetpeering2 'modules/network/vnetpeering.bicep' = {
  scope: resourceGroup
  name: 'sncvnetpeering2'
  params: {
    remoteVirtualNetworkId: virtualNetwork.outputs.vnetId
    vnetName: virtualNetwork2.outputs.vnetName
    remoteVnetName: virtualNetwork.outputs.vnetName
    allowForwardedTraffic: false
    allowGatewayTransit: false
    allowVirtualNetworkAccess: false
    useRemoteGateways: false
  }
}

module storage 'modules/storageAccount/storageaccount.bicep' = {
  scope: resourceGroup
  name: variables.storageAccountName
  params: {
    kind: variables.kind
    location: variables.location
    sku: variables.sku
    storageAccountName: variables.storageAccountName
  }
}

// module appgw 'modules/network/appgateway.bicep' = {
//   scope: resourceGroup
//   name: 
//   params: {
//     appGWCapacity: 
//     appGWFrontendIPConfigurationName: 
//     appGWName: 
//     appGWSKU: 
//     appGWTier: 
//     location: 
//     publicIPAllocationMethod: 
//     publicIPName: 
//   }
// }
// module nsg 'modules/network/networksecuritygroups.bicep' = {
//   scope: resourceGroup
//   name: nsgName
//   params: {
//     location: location
//     nsgName: nsgName
//   }
// }

// module managedIdentity 'modules/identity/identity.bicep' = {
//   scope: resourceGroup
//   name: managedIdentityName
//   params: {
//     location: location
//     managedIdentityName: managedIdentityName 
//   }
// }

// module keyvault 'modules/keyvault/keyvault.bicep' = {
//   scope: resourceGroup
//   name: 'snckv123456'
//   params: {
//     keyvaultManagedIdentityObjectId: managedIdentity.outputs.objectId
//     keyVaultName: keyvaultName
//     location: location
//     skuFamily: 'A'
//     skuName: keyvaultSKUName
//   }
// }

// module databricks 'modules/databrick/databrick.bicep' = {
//   scope: resourceGroup
//   name: workspaceName
//   params: {
//     managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)
//     workspaceName: workspaceName
//     location: location
//   }
// }
