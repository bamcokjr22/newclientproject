targetScope = 'subscription'

param vnetName string = 'sncvnet'
param vnetAddressPrefix string = '10.0.0.0/16'
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
    dnsServer: variables.dnsServer
  }
  dependsOn: [
    resourceGroup
  ]
}

// [for i in range(0,3) : if (i == 0)
// module virtualNetwork2 './modules/network/network.bicep' = {
//   scope: az.resourceGroup(resourceGroups[0])
//   name: vnetName2
//   params: {
//     location: variables.location
//     subnets: variables.subnets2
//     // subnetPrefixes: variables.subnets.subnetPrefix
//     vnetAddressPrefix: vnetAddressPrefix2
//     vnetName: vnetName2
//     nsgs: nsgs
//     routeTableId: routeTable.outputs.routeTableId
//     dnsServer: variables.dnsServer
//   }
//   dependsOn: [
//     resourceGroup
//   ]
// }

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
//   scope: az.resourceGroup('9606f0a1-4502-4c86-8f75-660af3fdb023', 'Ansible-RG')
//   name: 'vhub'
// }

// module vnetpeering3 'modules/network/vnetpeering.bicep' = {
//   scope: az.resourceGroup('9606f0a1-4502-4c86-8f75-660af3fdb023', 'Ansible-RG')
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
    isHnsEnabled: variables.storageAccounts[i].isHnsEnabled
    allowBlobPublicAccess: variables.storageAccounts[i].allowBlobPublicAccess
    principalId: managedIdentity.outputs.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  }
  dependsOn: [
    resourceGroup
  ]
}]


module blobPrivateDNSZone 'modules/network/privateDNSZone.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: variables.blobDNS
  params: {
    privateDNSZoneName: variables.blobDNS
    registrationEnabled: false
    vnetId: virtualNetwork.outputs.vnetId
  }
  dependsOn: [
    resourceGroup
  ]
}

module dfsPrivateDNSZone 'modules/network/privateDNSZone.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: variables.dfs
  params: {
    privateDNSZoneName: variables.dfs
    registrationEnabled: false
    vnetId: virtualNetwork.outputs.vnetId
  }
  dependsOn: [
    resourceGroup
  ]
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
    groupId: (variables.storageAccounts[i].isHnsEnabled ? 'dfs' : 'blob')
    // privateDNSZoneName: 'privatelink.blob.core.windows.net'
    privateDNSZoneId: (variables.storageAccounts[i].isHnsEnabled ? dfsPrivateDNSZone.outputs.dnsZoneId : blobPrivateDNSZone.outputs.dnsZoneId)
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
  dependsOn: [
    resourceGroup
  ]
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

module apim 'modules/apim.bicep' = {
  scope: az.resourceGroup(resourceGroups[1])
  name: 'sncapim-14'
  params: {
    apimName: 'sncapim-14'
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
  name: 'apim14-PE'
  params: {
    privateEndpointName: 'apim14-PE'
    privateLinkServiceName: 'sncpls'
    subnetName:  variables.subnets[0].name //apimSubnet.name // 
    vNetName:  vnetName //apimvnet.name //
    vNetResourceGroup: resourceGroups[0] // 'biceptest-rg' // 
    location: variables.location
    privateLinkServiceId: apim.outputs.apimId
    groupId: 'Gateway'
    privateDNSZoneId: apimPrivateDNSZone.outputs.dnsZoneId
    privateEndpointDnsGroupName: 'apim14-PE'
  }
  dependsOn: [
    resourceGroup
    apim
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

module databricksPrivateDNSZone 'modules/network/privateDNSZone.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: variables.databricks_ui_api
  params: {
    privateDNSZoneName: variables.databricks_ui_api
    registrationEnabled: false
    vnetId: virtualNetwork.outputs.vnetId
  }
  dependsOn: [
    resourceGroup
  ]
}

module databricks 'modules/databrick/databrick.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: workspaceName
  params: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)
    workspaceName: workspaceName
    location: variables.location
    privateSubnetName: variables.subnets[2].name
    publicSubnetName: variables.subnets[3].name
    virtualNetworkId: virtualNetwork.outputs.vnetId
  }
}

module databricksPrivateEndpoint 'modules/network/privateEndpoint.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: 'adb-PE'
  params: {
    privateEndpointName: 'adb-PE'
    privateLinkServiceName: 'sncpls'
    subnetName: variables.subnets[0].name
    vNetName: vnetName
    vNetResourceGroup: resourceGroups[0]
    location: variables.location
    privateLinkServiceId: databricks.outputs.workspaceId
    groupId: 'databricks_ui_api'
    // privateDNSZoneName: 'privatelink.blob.core.windows.net'
    privateDNSZoneId: databricksPrivateDNSZone.outputs.dnsZoneId
    privateEndpointDnsGroupName: 'adb-PE'
  }
  dependsOn: [
    databricks
  ]
}
