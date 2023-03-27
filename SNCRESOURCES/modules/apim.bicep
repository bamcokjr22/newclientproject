param apimName string
param location string
param apimSKUCapacity int
param apimSKUName string
param apimVirtualNetworkType string
param apimPublisherEmail string
param apimPublisherName string
param subnetId string
param apimVirtualNetworkTypeEnabled bool

resource apiManagementInstance 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apimName
  location: location
  sku:{
    capacity: apimSKUCapacity
    name: apimSKUName
  }
  properties:{
    virtualNetworkConfiguration: {
      subnetResourceId: subnetId
    }
    virtualNetworkType: (apimVirtualNetworkTypeEnabled) ? apimVirtualNetworkType : 'None'
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
    // privateEndpointConnections: [
    //   {
    //     id: 
    //     name: ''
    //     properties: {
    //       privateEndpoint: {
            
    //       }
    //       privateLinkServiceConnectionState: {
    //         actionsRequired: ''
    //         description: ''
    //         status: ''
    //       }
    //     }
    //     type: ''
    //   }
    // ]
    
  }
}
