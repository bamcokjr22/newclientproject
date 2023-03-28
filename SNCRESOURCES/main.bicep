targetScope = 'subscription'

param vnetName string = 'sncvnet'
param vnetName2 string = 'sncvnet2'
// param location string = 'CentralUS'
// param subnetName array = ['sncsubnet', 'apimSubnet']
// param subnetPrefix array = ['10.0.0.0/24', '10.0.1.0/24']
param vnetAddressPrefix string = '10.0.0.0/16'
param vnetAddressPrefix2 string = '192.168.0.0/16'
param keyvaultSKUName string = 'standard'
param keyvaultName string = 'sncaiskv1234567'
param managedIdentityName string = 'ucmanagedid'
param workspaceName string = 'sncaisdatabricks'

var managedResourceGroupName = 'databricks-rgs-${workspaceName}'

param createStorage bool = true

param resourceGroups array = ['snc-dev-poc-rg' 
'snc-dev-poc2-rg' 
'snc-dev-poc3-rg'
]
// var resourceGroups = [
//   'snc-dev-poc-rg'
//   'snc-dev-poc2-rg'
//   'snc-dev-poc3-rg'
// ]

// param variables object = loadJsonContent('parameter.json')

param nsgs object = loadJsonContent('parameter.json')

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = [ for resourceGroupName in resourceGroups: {
  name: resourceGroupName
  location: variables.location
}]

var variables = loadJsonContent('parameter.json')

module routeTable 'modules/network/userdefinedroute.bicep' = {
  scope: az.resourceGroup(resourceGroups[0])
  name: 'sncroutetable'
  params: {
    location: variables.location
    routeTableAddressPrefix: variables.routeTableAddressPrefix
    routeTableName: variables.routeTableName
    routeName: variables.routeName
    routeTableNextHopIPAddress: variables.routeTableNextHopIPAddress
    routeTableNextHopType: variables.routeTableNextHopType
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork './modules/network/network.bicep' = {
  scope: az.resourceGroup(resourceGroups[0])
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
  dependsOn: [
    resourceGroup
  ]
}

// [for i in range(0,3) : if (i == 0)
module virtualNetwork2 './modules/network/network.bicep' = {
  scope: az.resourceGroup(resourceGroups[0])
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
  dependsOn: [
    resourceGroup
  ]
}

// module vnetpeering1 'modules/network/vnetpeering.bicep' = {
//   scope: az.resourceGroup(resourceGroups[0])
//   name: 'sncvnetpeering1'
//   params: {
//     remoteVirtualNetworkId: virtualNetwork2.outputs.vnetId
//     vnetName: virtualNetwork.outputs.vnetName
//     remoteVnetName: virtualNetwork2.outputs.vnetName
//     allowForwardedTraffic: false
//     allowGatewayTransit: false
//     allowVirtualNetworkAccess: false
//     useRemoteGateways: false
//   }
//   dependsOn: [
//     virtualNetwork
//   ]
// }

// module vnetpeering2 'modules/network/vnetpeering.bicep' = {
//   scope: az.resourceGroup(resourceGroups[0])
//   name: 'sncvnetpeering2'
//   params: {
//     remoteVirtualNetworkId: virtualNetwork.outputs.vnetId
//     vnetName: virtualNetwork2.outputs.vnetName
//     remoteVnetName: virtualNetwork.outputs.vnetName
//     allowForwardedTraffic: false
//     allowGatewayTransit: false
//     allowVirtualNetworkAccess: false
//     useRemoteGateways: false
//   }
//   dependsOn: [
//     virtualNetwork2
//   ]
// }

// resource vhub 'Microsoft.Network/virtualHubs@2022-09-01' existing = {
//   scope: az.resourceGroup(resourceGroups[2])
//   name: reference(subscription().subscriptionId, resourceGroups[0], '')
// }

// module vnetpeering3 'modules/network/vnetpeering.bicep' = {
//   scope: az.resourceGroup(resourceGroups[2])
//   name: 'snchubcon'
//   params: {
//     peeringName: 'snchubcon'
//     vnetId: virtualNetwork.outputs.vnetId
//     vhubName: vhub.name
//   }
// }

// module privateDNS 'modules/network/privateDNSZone.bicep' = {
//   scope: az.resourceGroup(resourceGroups[0])
//   name: 'sncdns'
//   params: {
//     location: 'global'
//     privateDNSZoneName: 'sncdns.com'
//   }
// }
// module vnetpeering3 'modules/network/vnetpeering.bicep' = {
//   scope: az.resourceGroup(resourceGroups[0])
//   name: 'sncvnetpeering3'
//   params: {
//     remoteVirtualNetworkId: resourceId(subscription().subscriptionId, resourceGroups[2], 'Microsoft.Network/virtualHubs', vhub.name)
//     vnetName: virtualNetwork.outputs.vnetName
//     remoteVnetName: virtualNetwork.name
//     allowForwardedTraffic: true
//     allowGatewayTransit: true
//     allowVirtualNetworkAccess: true
//     useRemoteGateways: true
//   }
//   dependsOn: [
//     virtualNetwork
//   ]
// }

module storage 'modules/storageAccount/storageaccount.bicep' = [for (storageAccount, i) in variables.storageAccounts: if (createStorage) {
  scope: az.resourceGroup(resourceGroups[1])
  name: variables.storageAccounts[i].name
  params: {
    location: variables.location
    kind: variables.storageAccounts[i].kind
    sku: variables.storageAccounts[i].sku
    storageAccountName: variables.storageAccounts[i].name
  }
}]

module privateDNSZone 'modules/network/privateDNSZone.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: variables.blobDNS
  params: {
    privateDNSZoneName: variables.blobDNS
    registrationEnabled: false
    vnetId: virtualNetwork.outputs.vnetId
  }
}

module storageAccountPrivateEndpoint 'modules/network/privateEndpoint.bicep' = [for (storageAcount, i) in variables.storageAccounts: if (createStorage) {
  scope: az.resourceGroup(resourceGroups[2])
  name: '${variables.storageAccounts[i].name}-PE'
  params: {
    privateEndpointName: '${variables.storageAccounts[i].name}-PE'
    privateLinkServiceName: 'sncpls'
    subnetName: variables.subnets[0].name
    vNetName: vnetName
    vNetResourceGroup: resourceGroups[0]
    location: variables.location
    privateLinkServiceId: storage[i].outputs.storageAccountId
    groupId: 'blob'
    // privateDNSZoneName: 'privatelink.blob.core.windows.net'
    privateDNSZoneId: privateDNSZone.outputs.dnsZoneId
    privateEndpointDnsGroupName: '${variables.storageAccounts[i].name}-PE'
  }
  dependsOn: [
    storage
  ]
}]

module managedIdentity 'modules/identity/identity.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: managedIdentityName
  params: {
    location: variables.location
    managedIdentityName: managedIdentityName 
  }
}

// module keyvault 'modules/keyvault/keyvault.bicep' = {
//   scope: az.resourceGroup(resourceGroups[1])
//   name: 'sncaiskv1234567'
//   params: {
//     keyvaultManagedIdentityObjectId: managedIdentity.outputs.objectId
//     keyVaultName: keyvaultName
//     location: variables.location
//     skuFamily: 'A'
//     skuName: keyvaultSKUName
//   }
// }

module apim 'modules/apim.bicep' = {
  scope: az.resourceGroup(resourceGroups[1])
  name: 'sncaisapim'
  params: {
    apimName: 'sncaisapim'
    apimPublisherEmail: 'emmachi72.ec@gmail.com'
    apimPublisherName: 'Uchenna Chibueze'
    apimSKUCapacity: 1
    apimSKUName: 'Developer'
    apimVirtualNetworkType: 'Internal' 
    location: variables.location
    subnetId: resourceId(subscription().subscriptionId, resourceGroups[0], 'Microsoft.Network/virtualNetworks/subnets', vnetName, variables.subnets[1].name)
    apimVirtualNetworkTypeEnabled: false
    // privateEndpointId: resourceId('Microsoft.Network/privateEndpoints', apimAccountPrivateEndpoint.name)
  }
  dependsOn: [
    resourceGroup
  ]
}

module apimAccountPrivateEndpoint 'modules/network/privateEndpoint.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: 'apim-PE'
  params: {
    privateEndpointName: 'apim-PE'
    privateLinkServiceName: 'sncpls'
    subnetName: variables.subnets[0].name
    vNetName: vnetName
    vNetResourceGroup: resourceGroups[0]
    location: variables.location
    privateLinkServiceId: apim.outputs.apimId
    groupId: 'Gateway'
    // privateDNSZoneName: 'privatelink.blob.core.windows.net'
    privateDNSZoneId: apimPrivateDNSZone.outputs.dnsZoneId
    privateEndpointDnsGroupName: 'apim-PE'
  }
  dependsOn: [
    resourceGroup
  ]
}

module apimPrivateDNSZone 'modules/network/privateDNSZone.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: variables.Gateway
  params: {
    privateDNSZoneName: variables.Gateway
    registrationEnabled: false
    vnetId: virtualNetwork.outputs.vnetId
  }
  dependsOn: [
    resourceGroup
  ]
}


// module appGateway 'modules/network/appgateway.bicep' = {
//   scope: az.resourceGroup(resourceGroups[2])
//   name: 'sncappgw'
//   params: {
//     location: variables.location
//     applicationGatewayName: 'SNCApplicationGateway'
//     sku: 'WAF_v2'
//     tier: 'WAF_v2'
//     zoneRedundant: false
//     enableWebApplicationFirewall: false
//     firewallPolicyName: 'MyFirewallPolicyName'
//     publicIpAddressName: 'sncappgwpip'
//     vNetResourceGroup: resourceGroup[0].name
//     vNetName: virtualNetwork.name
//     subnetName: variables.subnets[2].name
//     frontEndPorts: [
//       {
//         name: 'port_80'
//         port: 80
//       }
//     ]
//     httpListeners: [
//       {
//         name: 'MyHttpListener'
//         protocol: 'Http'        
//         frontEndPort: 'port_80'
//       }
//     ]
//     backendAddressPools: [
//       {
//         name: 'MyBackendPool'
//         backendAddresses: [
//           {
//             ipAddress: '10.1.2.3'
//           }
//         ]
//       }
//     ]
//     backendHttpSettings: [
//       {
//         name: 'MyBackendHttpSetting'
//         port: 80
//         protocol: 'Http'
//         cookieBasedAffinity: 'Enabled'
//         affinityCookieName: 'MyCookieAffinityName'
//         requestTimeout: 300
//         connectionDraining: {
//           drainTimeoutInSec: 60
//           enabled: true
//         }
//       }
//     ]
//     rules: [
//       {
//         name: 'MyRuleName'
//         ruleType: 'Basic'
//         listener: 'MyHttpListener'
//         backendPool: 'MyBackendPool'
//         backendHttpSettings: 'MyBackendHttpSetting'
//       }
//     ]
//     // enableDeleteLock: true
//     // enableDiagnostics: true
//     // logAnalyticsWorkspaceId: ''
//     // diagnosticStorageAccountId: ''
//   }
//   dependsOn: [
//     virtualNetwork
//     virtualNetwork2
//   ]
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
