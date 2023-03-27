param storageAccountName string
param location string
param kind string
param sku string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: kind
  sku: {
    name: sku
  }
}


output storageAccountId string = storageaccount.id
