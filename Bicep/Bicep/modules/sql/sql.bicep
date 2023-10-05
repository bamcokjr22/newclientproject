metadata name = 'SQL Module'
metadata description = 'Module used to create SQL Server and Database'

@description('SQL Server Name')
param sqlServerName string
@description('SQL Database Name')
param sqlDBName string
@description('Location of SQL Server and Database')
param location string
@description('Identity Type which can be either SystemAssigned, UserAssigned, Both or None')
param identityType string
@description('Administrator Login Username')
param adminUsername string
@description('Administrator Login Passsword')
@secure()
param adminPassword string
@description('Parameter to either enable or disable Azure Authentication')
param azureADOnlyAuthentication bool
@description('Azure Authentication Login name of the server administrator.')
param azureADLoginName string
@description('Pricipal Type')
param principalType string
@description('Identity to add to SQL')
param sqlSID string
@description('Tenant ID')
param tenantId string
@description('Disable or Enable Public Network Access')
param sqlPublicNetworkAccess string
@description('Check to enable or disable vulnerability assessment')
param enableVA bool = false
@description('Decide whether to enable or disable VA Managed Identity')
param useVAManagedIdentity bool = false
@description('Enable or Disable Azure IPs')
param allowAzureIps bool = true
@description('SQL Start Allowed IPs')
param sqlStartIpAddress string
@description('SQL End Allowed Ips')
param sqlEndIpAddress string
@description('Enable ADS')
param enableADS bool = false
@description('Storage Account Name to Reference')
param storageAccountName string
@description('SQL Database SKU Name')
param sqlDBSkuName string
@description('SQL Database SKU Tier')
param sqlDBSkuTier string
@description('SQL Database SKU Family')
param sqlDBSkuFamily string
@description('SQL Database SKU Capacity')
param sqlDBSkuCapacity int
@description('SKU Name of Storage Account')
param storgaeAccountSkuName string
@description('Kind of Storage Account')
param storageAccounKind string
@description('Principal ID for SQL VA storage Account')
param princapalId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (enableVA) {
  name: storageAccountName
  location: location
  sku: {
    name: storgaeAccountSkuName
  }
  kind: storageAccounKind
}

resource storageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

resource storageAccountBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccountBlob
  name: 'vulnerability-assessment'
}

resource storageAccountRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(useVAManagedIdentity) {
  name: 'sqlvaroleassignment'
  scope: storageAccount
  properties: {
    principalId: princapalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'ServicePrincipal'
  }
}

resource sql 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  identity: {
    type: (enableVA && useVAManagedIdentity) ? 'SystemAssigned' : 'None'
    userAssignedIdentities: ((identityType == 'SystemAssigned ' || identityType == 'None') ? null : {})
  }
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: azureADOnlyAuthentication
      login: azureADLoginName
      principalType: principalType
      sid: sqlSID
      tenantId: tenantId
    }
    publicNetworkAccess: sqlPublicNetworkAccess
    minimalTlsVersion: '1.2'
  }
  tags: {}
}

resource sqlFirewall 'Microsoft.Sql/servers/firewallRules@2021-11-01' = if (allowAzureIps) {
  parent: sql
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: sqlStartIpAddress
    endIpAddress: sqlEndIpAddress
  }
}

resource sqlServerAuditingPolicy 'Microsoft.Sql/servers/auditingPolicies@2014-04-01' = {
  parent: sql
  name: 'default'
  properties: {
    auditingState: 'Disabled'
  }
}

resource sqlServerAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2021-11-01' = {
  parent: sql
  name: 'default'
  properties: {
    state: 'Enabled'
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
    isAzureMonitorTargetEnabled: true
  }
}

resource sqlSecurityAlertPolicies 'Microsoft.Sql/servers/securityAlertPolicies@2021-11-01' = if(enableADS) {
  parent: sql
  name: 'Default'
  properties: {
    state: 'Enabled'
    emailAccountAdmins: true
  }
}

resource sqlVA 'Microsoft.Sql/servers/vulnerabilityAssessments@2021-11-01' = if (enableVA) {
  parent: sql
  name: 'default'
  dependsOn: [sqlSecurityAlertPolicies]
  properties: {
    storageContainerPath: enableVA ? storageAccountName : ''
    storageAccountAccessKey: ((enableVA) && !(useVAManagedIdentity)) ? storageAccount.listKeys().keys[0].value : ''
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: true
    }
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sql
  name: sqlDBName
  location: location
  sku: {
    name: sqlDBSkuName
    tier: sqlDBSkuTier
    family:sqlDBSkuFamily
    capacity: sqlDBSkuCapacity
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 5368709120
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60
    minCapacity: 5/10
    secondaryType: 'GRS'
  }
}

resource sqlDBAuditingPolicies 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  parent: sqlDB
  name: 'default'
  properties: {
    auditingState: 'Disabled'
  }
}

resource sqlDBAuditingSettings 'Microsoft.Sql/servers/databases/auditingSettings@2021-11-01' = {
  parent: sqlDB
  name: 'default'
  properties: {
    state: 'Enabled'
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
    isAzureMonitorTargetEnabled: true
  }
}

resource sqlDBExtendedAuditingSettings 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2021-11-01' = {
  parent: sqlDB
  name: 'default'
  properties: {
    state: 'Enabled'
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
    isAzureMonitorTargetEnabled: true
  }
}

resource sqlDBGeoBackupPolicies 'Microsoft.Sql/servers/databases/geoBackupPolicies@2021-11-01' = {
  parent: sqlDB
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
}

resource sqlDBSecurityAlertPolicies 'Microsoft.Sql/servers/databases/securityAlertPolicies@2021-11-01' = {
  parent: sqlDB
  name: 'default'
  properties: {
    state: 'Disabled'
  }
}

resource sqlDBTransparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01' = {
  parent: sqlDB
  name: 'current'
  properties: {
    state: 'Enabled'
  }
}

resource vulnerabilityAssessments 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2021-11-01' = {
  parent: sqlDB
  name: 'default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
}

output sqlId string = sql.id
