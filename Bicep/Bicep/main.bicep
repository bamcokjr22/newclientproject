targetScope = 'subscription'

param location string = 'West Europe'

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'test-rg'
  location: location
}

module userAssignedIdentity 'modules/managedidentity/managedidentity.bicep' = {
  scope: rg
  name: 'uctestpoc'
  params: {
    location: location
    managedidentityName: 'uctestpoc' 
  }
}
module sql 'modules/sql/sql.bicep' = {
  scope: rg
  name: 'sql'
  params: {
    adminPassword: '@!234getaXlease'
    adminUsername: 'serveradmin'
    azureADLoginName: 'akstflearn admins'
    azureADOnlyAuthentication: false
    identityType: 'SystemAssigned'
    location: location
    principalType: 'Group' 
    sqlDBName: 'ucdb'
    sqlPublicNetworkAccess: 'Disabled'
    sqlServerName: 'ucsqlsrv'
    sqlSID: 'c2535c34-5078-4552-b708-45d6c8167951'
    tenantId: tenant().tenantId 
  }
}

module vnet 'modules/virtualnetwork/virtualnetwork.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    location: location
    subnets: [{
      name: 'asp'
      subnetPrefix: '192.168.1.0/24'
    }
    {
      name: 'pe'
      subnetPrefix: '192.168.2.0/24'
    }]
    vnetAddressPrefixes: ['192.168.0.0/16']
    vnetName: 'testvnet'
  }
}

module loganalytics 'modules/loganalytics/loganalytics.bicep' = {
  scope: rg
  name: 'ucwrksp'
  params: {
    location: location
    workspaceName: 'ucwrksp'
    loganalyticsSkuName: 'PerGB2018'
  }
}

module storageaccount 'modules/storageAccount/storageaccount.bicep' = {
  scope: rg
  name: 'newuctestsa'
  params: {
    kind: 'StorageV2'
    location: location
    skuName: 'Standard_LRS'
    storageAccountName: 'newuctestsa'
  }
}

module storagepe 'modules/privateendpoint/privateendpoint.bicep' = {
  scope: rg
  name: 'stoacctpe'
  params: {
    customNetworkInterfaceName: 'stoacctpe'
    location: location
    privateEndpointName: 'stoacctpe'
    subnetId: vnet.outputs.subnets[1].resourceId
    subnetName: vnet.outputs.subnets[1].subnetName
    peserviceId: storageaccount.outputs.stoacctId
    groupId: 'blob'
  }
}

module sqlserverpe 'modules/privateendpoint/privateendpoint.bicep' = {
  scope: rg
  name: 'sqlserverpe'
  params: {
    customNetworkInterfaceName: 'sqlserverpe'
    location: location
    privateEndpointName: 'sqlserverpe'
    subnetId: vnet.outputs.subnets[1].resourceId
    subnetName: vnet.outputs.subnets[1].subnetName
    peserviceId: sql.outputs.sqlId
    groupId: 'sqlServer'
  }
}

module appservicePlan 'modules/asp/asp.bicep' = {
  scope: rg
  name: 'ucasp'
  params: {
    aspKind: 'linux'
    aspName: 'ucasp'
    aspSkuName: 'B1'
    aspSkuTier: ''
    location: location
    aspReserved: true
  }
}

module appservice 'modules/appservice/appservice.bicep' = {
  scope: rg
  name: 'ucwebapptest'
  params: {
    appInsightApplicationType: 'web'
    appInsightKind: 'web'
    appInsightName: 'ucwebapptest'
    appserviceAlwaysOn: true 
    appserviceName: 'ucwebapptest'
    location: location
    logAnalyticsWorkspaceResourceId: loganalytics.outputs.workspaceId
    serverfarmId: appservicePlan.outputs.appserviceplanId
    vnetRouteAllEnabled: false
  }
}

module appservicepe 'modules/privateendpoint/privateendpoint.bicep' = {
  scope: rg
  name: 'appservicepe'
  params: {
    customNetworkInterfaceName: 'appservicepe'
    location: location
    privateEndpointName: 'appservicepe'
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
    keyvaultName: 'ucpockv' 
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

module keyvaultpe 'modules/privateendpoint/privateendpoint.bicep' = {
  scope: rg
  name: 'keyvaultpe'
  params: {
    customNetworkInterfaceName: 'keyvaultpe'
    location: location
    privateEndpointName: 'keyvaultpe'
    subnetId: vnet.outputs.subnets[1].resourceId
    subnetName: vnet.outputs.subnets[1].subnetName
    peserviceId: keyvault.outputs.keyvaultId
    groupId: 'vault'
  }
}
