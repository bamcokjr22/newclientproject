metadata name = 'PrivateEndpoint Module'
metadata description = 'Module used to create private endpoint'

@description('Private Endpoint Name')
param privateEndpointName string
@description('Location of PrivateEndpoint')
param location string
@description('Subnet Id of Private Endpoint')
param subnetId string
@description('Subnet Name of Private Endpoint')
param subnetName string
@description('Name of Network Interface of Private Endpoint')
param customNetworkInterfaceName string
@description('Identity of the Target Resource to Connect Private Endpoint')
param peserviceId string
@description('Target Sub Resource')
param groupId string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
      name: subnetName
    }
    customNetworkInterfaceName: customNetworkInterfaceName
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: peserviceId
          groupIds: [groupId]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }   
        }
      }
    ]
  }
  tags: {}
}
