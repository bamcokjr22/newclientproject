metadata name = 'App Service Plan Module'
metadata description = 'Module used to create app service plan'

@description('The name of the app service plan')
param aspName string
@description('The location of the app service plan')
param location string
@description('The App Service Plan SKU Name')
param aspSkuName string
@description('The App Service Plan SKU Tier')
param aspSkuTier string
@description('The App Service Plan Kind')
param aspKind string
@description('Reserved Properties which is set to false when Windows and true when Linux')
param aspReserved bool

resource appserviceplan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: aspName
  location: location
  sku: {
    name: aspSkuName
    tier: aspSkuTier
  }
  kind: aspKind
  properties: {
    reserved: aspReserved
  }
  tags: {}
}

output appserviceplanId string = appserviceplan.id
