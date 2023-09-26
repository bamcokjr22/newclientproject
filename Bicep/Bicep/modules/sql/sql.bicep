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

resource sql 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  identity: {
    type: identityType
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

resource sqlDB 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sql
  name: sqlDBName
  location: location
}

output sqlId string = sql.id
