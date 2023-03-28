param apimName string
param location string
param apimSKUCapacity int
param apimSKUName string
param apimVirtualNetworkType string
param apimPublisherEmail string
param apimPublisherName string
param subnetId string
param apimVirtualNetworkTypeEnabled bool
// param privateEndpointId string

resource apiManagementInstance 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apimName
  location: location
  sku:{
    capacity: apimSKUCapacity
    name: apimSKUName
  }
  properties:{
    virtualNetworkConfiguration: (apimVirtualNetworkTypeEnabled == false) ? null : {
      subnetResourceId: subnetId
    }
    virtualNetworkType: (apimVirtualNetworkTypeEnabled) ? apimVirtualNetworkType : 'None'
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
    // privateEndpointConnections: [
    //   {
    //     id: privateEndpointId
    //     name: 'apimpe'
    //     properties: {
    //       // privateEndpoint: {}
    //       privateLinkServiceConnectionState: {
    //         // actionsRequired: ''
    //         description: 'Approved by automated script'
    //         status: 'Approved'
    //       }
    //     }
    //     // type: ''
    //   }
    // ]
    
  }
}


output apimId string = apiManagementInstance.id
