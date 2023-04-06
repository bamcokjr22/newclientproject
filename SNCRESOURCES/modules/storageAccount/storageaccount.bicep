param storageAccountName string
param location string
param kind string
param sku string
param isHnsEnabled bool
param allowBlobPublicAccess bool

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: kind
  sku: {
    name: sku
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    isHnsEnabled: isHnsEnabled
    allowBlobPublicAccess: allowBlobPublicAccess
  }
}

param principalId string
param roleDefinitionId string
resource storageRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageaccount
  name: guid(principalId, roleDefinitionId, storageAccountName)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
  }
}

output storageAccountId string = storageaccount.id
