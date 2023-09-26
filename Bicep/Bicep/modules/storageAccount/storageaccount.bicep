metadata name = 'Storage Account Module'
metadata description = 'Module used to create storage account'

@description('Storage Account Name')
param storageAccountName string
@description('Location of Storage Account')
param location string
@description('SKU Name of Storage Account')
param skuName string
@description('Kind of Storage Account')
param kind string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: kind
}

output stoacctId string = storageAccount.id
