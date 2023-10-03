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
param Environment string
param Application string
param Cost_Center_App_Services string
param Data_Classification string
param Portfolio_Group string
param Project_Number string
param Business_Unit string
param Name_App_Services string
param DR_Tier string
param Role_App_Services string
param privateDnsZoneName string


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
    manualPrivateLinkServiceConnections: []
    customDnsConfigs: []
  }
  tags: {
    Role: Role_App_Services
		Name: Name_App_Services
		Application: Application
		Business_Unit: Business_Unit
		Cost_Center: Cost_Center_App_Services
		Data_Classification: Data_Classification
		DR_Tier: DR_Tier
		Environment: Environment
		Portfolio_Group: Portfolio_Group
		Project_Number: Project_Number
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpoint
  name: privateEndpointName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneName
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  } 
}
