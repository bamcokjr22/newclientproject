@description('Private Link Service name')
param privateLinkServiceName string

@description('PrivateEndpoint name')
param privateEndpointName string

@description('Resource Group where the Vnet is Deployed')
param vNetResourceGroup string

@description('Name of the Vnet')
param vNetName string

@description('Name of the subnet')
param subnetName string

@description('Resource Id which requires private endpoint')
param privateLinkServiceId string

param groupId string

@description('Location')
param location string

param privateEndpointDnsGroupName string

// param privateDNSZoneName string

param privateDNSZoneId string

// resource privateLinkService 'Microsoft.Network/privateLinkServices@2022-09-01' = {
//   name: privateLinkServiceName
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: ''
//         properties: {
//           privateIPAllocationMethod: 'Dynamic'
//           privateIPAddress: 'IPv4'
//           subnet: {
//             id: resourceId(subscription().subscriptionId, vNetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, subnetName)
//           }
//           primary: false
//         }
//       }
//     ]
//   }
// }

// resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateDnsZone
//   name: '${privateDnsZoneName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateLinkServiceName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            groupId
          ]
          
        }
      }
    ]
    subnet: {
      id: resourceId(subscription().subscriptionId, vNetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, subnetName)
    }
  }
}

resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
  name:'${privateEndpointDnsGroupName}/mydnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDNSZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
