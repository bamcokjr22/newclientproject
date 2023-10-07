metadata name = 'KeyVault Module'
metadata description = 'Module used to create key vault'

@description('Keyvault Name')
param keyvaultName string
@description('Location of Keyvault')
param location string
@description('Keyvault SKU Name')
param skuName string
@description('Tenant ID')
param tenantId string
@description('Object ID of Managed Identity')
param objectId string
@description('Permissions om Certificate access policy')
param certificatePermissions array
@description('Permissions on Key Access Policy')
param keyPermissions array
@description('Permissions on Secret Access Policy')
param secretPermissions array
@description('Permissions on Storage Access Policy')
param storagePermissions array
@description('Enable or Disable Public Network Access')
param publicNetworkAccess string
param subnetId string

@description('keyvault SKU Family')
var skuFamily = 'A'

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyvaultName
  location: location
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        permissions: {
          certificates: certificatePermissions
          keys: keyPermissions
          secrets: secretPermissions
          storage: storagePermissions
        }
        tenantId: tenantId
      }
    ]
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          ignoreMissingVnetServiceEndpoint: false
          id: subnetId
        }
      ]
    }
    sku: {
      family: skuFamily
      name: skuName
    }
    tenantId: tenantId
  }
  tags: {}
}

output keyvaultId string = keyvault.id
