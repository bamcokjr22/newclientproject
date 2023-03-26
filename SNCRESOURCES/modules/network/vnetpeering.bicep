// param vnetName string
// param remoteVnetName string
// param allowVirtualNetworkAccess bool
// param allowForwardedTraffic bool
// param allowGatewayTransit bool
// param useRemoteGateways bool
// param remoteVirtualNetworkId string
param peeringName string
param vnetId string
param vhubName string

// resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
//   name: '${vnetName}/${remoteVnetName}'
//   properties: {
//     allowVirtualNetworkAccess: allowVirtualNetworkAccess
//     allowForwardedTraffic: allowForwardedTraffic
//     allowGatewayTransit: allowGatewayTransit
//     useRemoteGateways: useRemoteGateways
//     remoteVirtualNetwork: {
//       id: remoteVirtualNetworkId
//     }
//   }
// }

resource hubpeering 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2022-09-01' = {
  name: '${vhubName}/${peeringName}'
  properties: {
    remoteVirtualNetwork: {
      id: vnetId
    }
  }
}
