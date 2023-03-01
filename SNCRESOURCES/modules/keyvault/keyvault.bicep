param keyVaultName string
param location string
param skuFamily string
param skuName string
param tenantId string
param accessPolicies array
param keyVaultAccessPolicyName string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: skuFamily
      name: skuName
    }
    tenantId: tenantId
  }
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: keyVaultAccessPolicyName
  properties: {
    accessPolicies: accessPolicies
  }
}
