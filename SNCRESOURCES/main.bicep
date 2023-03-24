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

module vnetpeering1 'modules/network/vnetpeering.bicep' = {
  scope: az.resourceGroup(resourceGroups[0])
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
  dependsOn: [
    virtualNetwork
  ]
}

module vnetpeering2 'modules/network/vnetpeering.bicep' = {
  scope: az.resourceGroup(resourceGroups[0])
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
  dependsOn: [
    virtualNetwork2
  ]
}

module storage 'modules/storageAccount/storageaccount.bicep' = {
  scope: az.resourceGroup(resourceGroups[1])
  name: variables.storageAccountName
  params: {
    kind: variables.kind
    location: variables.location
    sku: variables.sku
    storageAccountName: variables.storageAccountName
  }
  dependsOn: [
    resourceGroup
  ]
}

module appGateway 'modules/network/appgateway.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: 'sncappgw'
  params: {
    location: variables.location
    applicationGatewayName: 'SNCApplicationGateway'
    sku: 'WAF_v2'
    tier: 'WAF_v2'
    zoneRedundant: false
    enableWebApplicationFirewall: false
    firewallPolicyName: 'MyFirewallPolicyName'
    publicIpAddressName: 'sncappgwpip'
    vNetResourceGroup: resourceGroup[0].name
    vNetName: virtualNetwork.name
    subnetName: variables.subnets[2].name
    frontEndPorts: [
      {
        name: 'port_80'
        port: 80
      }
    ]
    httpListeners: [
      {
        name: 'MyHttpListener'
        protocol: 'Http'        
        frontEndPort: 'port_80'
      }
    ]
    backendAddressPools: [
      {
        name: 'MyBackendPool'
        backendAddresses: [
          {
            ipAddress: '10.1.2.3'
          }
        ]
      }
    ]
    backendHttpSettings: [
      {
        name: 'MyBackendHttpSetting'
        port: 80
        protocol: 'Http'
        cookieBasedAffinity: 'Enabled'
        affinityCookieName: 'MyCookieAffinityName'
        requestTimeout: 300
        connectionDraining: {
          drainTimeoutInSec: 60
          enabled: true
        }
      }
    ]
    rules: [
      {
        name: 'MyRuleName'
        ruleType: 'Basic'
        listener: 'MyHttpListener'
        backendPool: 'MyBackendPool'
        backendHttpSettings: 'MyBackendHttpSetting'
      }
    ]
    // enableDeleteLock: true
    // enableDiagnostics: true
    // logAnalyticsWorkspaceId: ''
    // diagnosticStorageAccountId: ''
  }
  dependsOn: [
    virtualNetwork
    virtualNetwork2
  ]
}

module privateEndpoint 'modules/network/privateEndpoint.bicep' = {
  scope: az.resourceGroup(resourceGroups[2])
  name: 'sncpe'
  params: {
    privateEndpointName: 'sncpe' 
    privateLinkServiceName: 'sncpls'
    subnetName: variables.subnets[0].name
    vNetName: vnetName
    vNetResourceGroup: resourceGroups[0]
    location: variables.location
    privateLinkServiceId: storage.outputs.storageAccountId
    groupId: 'blob'
  }
}
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
