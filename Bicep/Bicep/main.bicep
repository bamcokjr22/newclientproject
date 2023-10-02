targetScope = 'subscription'

param location string = 'EastUS'

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: 'CE-NonProd-E1-GenPortal-Dev-RG'
  // location: location
}

module userAssignedIdentity 'modules/managedidentity/managedidentity.bicep' = {
  scope: rg
  name: 'ManagedIdentity'
  params: {
    location: location
    managedidentityName: 'CE-NonProd-E1-GenPortal-Dev-MI' 
  }
  // tags: {
  //   		Role: 'App Services'
	// 			Name: 'CE-NonProd-E1-GenPortal-Dev-RG'
	// 			Application: 'GenPortal'
	// 			Business Unit: 'CE'
	// 			Cost Center: '3240783'
	// 			Data Classification: 'none'
	// 			DR Tier: 'none'
	// 			Environment: 'NonProd'
	// 			Portfolio Group: 'IT Electric Supply and Asset Management'
	// 			Project Number: 'PJT23780'
  // }
}
module sql 'modules/sql/sql.bicep' = {
  scope: rg
  name: 'sql'
  params: {
    adminPassword: 'sqladmin123'
    adminUsername: 'sqladmin'
    azureADLoginName: 'akstflearn admins'
    azureADOnlyAuthentication: false
    identityType: 'SystemAssigned'
    location: location
    principalType: 'Group' 
    sqlDBName: 'CE-NonProd-E1-GenPortalD001-DB'
    sqlPublicNetworkAccess: 'Disabled'
    sqlServerName: 'ce-nonprod-e1-GenPortal001-svr'
    sqlSID: '90d03d98-9772-4f62-864d-65160f632017'
    tenantId: tenant().tenantId 
  }
}

module vnet 'modules/virtualnetwork/virtualnetwork.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    location: location
    subnets: [{
      name: 'CE-NonProd-E1-External-AppX-Genapps-pe-sub-10.244.77.160_27'
      subnetPrefix: '10.244.77.160/27'
    }
    {
      name: 'CE-NonProd-E1-External-AppX-Database-pe-sub-10.244.79.16_28'
      subnetPrefix: '10.244.79.16/28'
    }
    {
      name: 'CE-NonProd-E1-External-AppX-AppService-sub-10.244.75.64_28'
      subnetPrefix: '10.244.75.64/28'
    }]
    vnetAddressPrefixes: ['10.244.252.0/22']
    vnetName: 'CE-NonProd-E1-External-AppX-VNet'
  }
}

// module loganalytics 'modules/loganalytics/loganalytics.bicep' = {
//   scope: rg
//   name: 'ucwrksp'
//   params: {
//     location: location
//     workspaceName: 'ucwrksp'
//     loganalyticsSkuName: 'PerGB2018'
//   }
// }

// module storageaccount 'modules/storageAccount/storageaccount.bicep' = {
//   scope: rg
//   name: 'newuctestsa'
//   params: {
//     kind: 'StorageV2'
//     location: location
//     skuName: 'Standard_LRS'
//     storageAccountName: 'newuctestsa'
//   }
// }

// module storagepe 'modules/privateendpoint/privateendpoint.bicep' = {
//   scope: rg
//   name: 'stoacctpe'
//   params: {
//     customNetworkInterfaceName: 'stoacctpe'
//     location: location
//     privateEndpointName: 'stoacctpe'
//     subnetId: vnet.outputs.subnets[1].resourceId
//     subnetName: vnet.outputs.subnets[1].subnetName
//     peserviceId: storageaccount.outputs.stoacctId
//     groupId: 'blob'
//   }
// }

// module sqlserverpe 'modules/privateendpoint/privateendpoint.bicep' = {
//   scope: rg
//   name: 'sqlserverpe'
//   params: {
//     customNetworkInterfaceName: 'sqlserverpe'
//     location: location
//     privateEndpointName: 'sqlserverpe'
//     subnetId: vnet.outputs.subnets[1].resourceId
//     subnetName: vnet.outputs.subnets[1].subnetName
//     peserviceId: sql.outputs.sqlId
//     groupId: 'sqlServer'
//   }
// }

module appservicePlan 'modules/asp/asp.bicep' = {
  scope: rg
  name: 'CE-NonProd-E1-GenPortald001-Dev-ASP'
  params: {
    aspKind: 'linux'
    aspName: 'CE-NonProd-E1-GenPortald001-Dev-ASP'
    aspSkuName: 'B1'
    aspSkuTier: ''
    location: location
    aspReserved: true
  }
}

module appservice 'modules/appservice/appservice.bicep' = {
  scope: rg
  name: 'CE-NonProd-E1-GenPortal-Dev-App'
  params: {
    appInsightApplicationType: 'web'
    appInsightKind: 'web'
    appInsightName: 'CE-NonProd-E1-GenPortal-Dev-App'
    appserviceAlwaysOn: true 
    appserviceName: 'CE-NonProd-E1-GenPortal-Dev-App'
    location: location
    logAnalyticsWorkspaceResourceId: loganalytics.outputs.workspaceId
    serverfarmId: appservicePlan.outputs.appserviceplanId
    vnetRouteAllEnabled: false
  }
}

module appservicepe 'modules/privateendpoint/privateendpoint.bicep' = {
  scope: rg
  name: 'CE-NonProd-E1-GenPortal-Dev-AppS_Ext-PE'
  params: {
    customNetworkInterfaceName: 'CE-NonProd-E1-GenPortal-Dev-AppS_Ext-PE'
    location: location
    privateEndpointName: 'CE-NonProd-E1-GenPortal-Dev-AppS_Ext-PE'
    subnetId: vnet.outputs.subnets[1].resourceId
    subnetName: vnet.outputs.subnets[1].subnetName
    peserviceId: appservice.outputs.appserviceId
    groupId: 'sites'
  }
}

module keyvault 'modules/keyvault/keyvault.bicep' = {
  scope: rg
  name: 'keyvault'
  params: {
    keyvaultName: 'CE-NonProd-E1-GenPortal-Dev-KeyVault' 
    location: location
    skuName: 'standard'
    tenantId: tenant().tenantId
    objectId: userAssignedIdentity.outputs.mangedidentityClientId
    publicNetworkAccess: 'Disabled'
    certificatePermissions: []
    keyPermissions: []
    secretPermissions: ['list', 'set', 'get']
    storagePermissions: []
  }
}

// module keyvaultpe 'modules/privateendpoint/privateendpoint.bicep' = {
//   scope: rg
//   name: 'keyvaultpe'
//   params: {
//     customNetworkInterfaceName: 'keyvaultpe'
//     location: location
//     privateEndpointName: 'keyvaultpe'
//     subnetId: vnet.outputs.subnets[1].resourceId
//     subnetName: vnet.outputs.subnets[1].subnetName
//     peserviceId: keyvault.outputs.keyvaultId
//     groupId: 'vault'
//   }
// }
