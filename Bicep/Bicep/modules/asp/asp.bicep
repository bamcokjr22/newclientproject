metadata name = 'App Service Plan Module'
metadata description = 'Module used to create app service plan'

@description('The name of the app service plan')
param App_Service_Plan_name string
@description('The location of the app service plan')
@allowed([
  'East US 2'
  'East US'
  'West Europe'
])
param location string
@description('The App Service Plan SKU Name')
param App_Service_Plan_sku_name string
@description('The App Service Plan SKU Tier')
param App_Service_Plan_sku_tier string
@description('The size of the App Service Plan')
param App_Service_Plan_size string
@description('The family of the App Service Plan')
param App_Service_Plan_family string
@description('The capacity of the App Service Plan')
param App_Service_Plan_capacity int
@description('The App Service Plan Kind')
param App_Service_Plan_kind string
@description('Reserved Properties which is set to false when Windows and true when Linux')
param App_Service_Plan_reserved bool

resource appserviceplan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: App_Service_Plan_name
  location: location
  sku: {
    name: App_Service_Plan_sku_name
    tier: App_Service_Plan_sku_tier
    size: App_Service_Plan_size
    family: App_Service_Plan_family
    capacity: App_Service_Plan_capacity
  }
  kind: App_Service_Plan_kind
  properties: {
    reserved: App_Service_Plan_reserved
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    isXenon: false
    hyperV: false
    targetWorkerCount:0
    targetWorkerSizeId: 0
  }
  tags: {}
}

output appserviceplanId string = appserviceplan.id
