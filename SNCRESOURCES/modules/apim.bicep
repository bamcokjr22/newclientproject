param apimName string
param location string
param apimSKUCapacity int
param apimSKUName string
param apimVirtualNetworkType string
param apimPublisherEmail string
param apimPublisherName string
param subnetId string

resource apiManagementInstance 'Microsoft.ApiManagement/service@2020-12-01' = {
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
    virtualNetworkType: apimVirtualNetworkType
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
}

