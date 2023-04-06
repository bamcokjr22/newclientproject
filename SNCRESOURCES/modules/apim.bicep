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
  properties: {
    virtualNetworkConfiguration: (apimVirtualNetworkTypeEnabled == false) ? null : {
      subnetResourceId: subnetId
    }
    virtualNetworkType: (apimVirtualNetworkTypeEnabled) ? apimVirtualNetworkType : 'None'
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
}


// resource diagSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
//   name: 'writeToLogAnalytics'
//   scope: apim
//   properties:{
//    logAnalyticsDestinationType: 'Dedicated'
//    workspaceId : workspace_id
//     logs:[
//       {
//         category: 'GatewayLogs'
//         enabled:true
//         retentionPolicy:{
//           enabled:false
//           days: 0
//         }
//       }         
//     ]
//     metrics:[
//       {
//         category: 'AllMetrics'
//         enabled:true
//         timeGrain: 'PT1M'
//         retentionPolicy:{
//          enabled:false
//          days: 0
//        }
//       }
//     ]
//   }
//  }

output apimId string = apiManagementInstance.id
