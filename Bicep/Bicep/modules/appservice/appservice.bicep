metadata name = 'App Service Module'
metadata description = 'The Module used to create App Service and App Insights'

@sys.description('App Service Name')
param appserviceName string
@description('Location of App Service and App Insights')
param location string
@description('App Service Plan ID')
param serverfarmId string
@description('App Insights Name')
param appInsightName string
@description('App Insight Kind')
param appInsightKind string
@description('App Insight Application Type')
param appInsightApplicationType string
@description('Log Analytics Workspace Id')
param logAnalyticsWorkspaceResourceId string
@description('Vnet Route')
param vnetRouteAllEnabled bool
@description('Always On for the App Service')
param appserviceAlwaysOn bool

resource appservice 'Microsoft.Web/sites@2022-09-01' = {
  name: appserviceName
  location: location
  properties: {
    serverFarmId: serverfarmId
    httpsOnly: true
    siteConfig: {
      alwaysOn: appserviceAlwaysOn
      minTlsVersion: '1.2'
    }
    vnetRouteAllEnabled: vnetRouteAllEnabled
  }
  tags: {}
}

resource appinsight 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: appInsightKind
  properties: {
    Application_Type: appInsightApplicationType
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
  tags: {}
}

resource appserviceLogging 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appservice
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: appinsight.properties.InstrumentationKey
  }
}

output appserviceId string = appservice.id
