metadata name = 'App Service Module'
metadata description = 'The Module used to create App Service and App Insights'

@description('App Service Name')
param Application_Name string
@description('Location of App Service and App Insights')
param location string
@description('App Service Plan ID')
param serverfarmId string
@description('App Insights Name')
param Application_Insights_Name string
@description('App Insight Kind')
param Application_Insights_Kind string
@description('App Insight Application Type')
param Application_Insights_Type string
@description('Log Analytics Workspace Id')
param logAnalyticsWorkspaceResourceId string
@description('Vnet Route')
param vnetRouteAllEnabled bool
@description('Always On for the App Service')
param appserviceAlwaysOn bool
@description('Application Insight Request Source')
param Application_Insights_Request_Source string
@description('Application Insight Public Network Access For Ingestion')
param Application_Insights_public_Network_Access_For_Ingestion string
@description('Application Insight Public Network Access For Query')
param Application_Insights_public_Network_Access_For_Query string
param Environment string
param Application string
param Cost_Center_App_Services string
param Data_Classification string
param Portfolio_Group string
param Project_Number string
param Business_Unit string
param Name_App_Services string
param DR_Tier string
param Role_App_Services string

resource appservice 'Microsoft.Web/sites@2022-09-01' = {
  name: Application_Name
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
  tags: {
    Role: Role_App_Services
		Name: Name_App_Services
		Application: Application
		Business_Unit: Business_Unit
		Cost_Center: Cost_Center_App_Services
		Data_Classification: Data_Classification
		DR_Tier: DR_Tier
		Environment: Environment
		Portfolio_Group: Portfolio_Group
		Project_Number: Project_Number
  }
}

resource appinsight 'Microsoft.Insights/components@2020-02-02' = {
  name: Application_Insights_Name
  location: location
  kind: Application_Insights_Kind
  properties: {
    Application_Type: Application_Insights_Type
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
    Request_Source: Application_Insights_Request_Source
    RetentionInDays: 90
    publicNetworkAccessForIngestion: Application_Insights_public_Network_Access_For_Ingestion
    publicNetworkAccessForQuery: Application_Insights_public_Network_Access_For_Query
  }
  tags: {
    Role: Role_App_Services
		Name: Name_App_Services
		Application: Application
		Business_Unit: Business_Unit
		Cost_Center: Cost_Center_App_Services
		Data_Classification: Data_Classification
		DR_Tier: DR_Tier
		Environment: Environment
		Portfolio_Group: Portfolio_Group
		Project_Number: Project_Number
  }
}

resource appserviceLogging 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appservice
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: appinsight.properties.InstrumentationKey
  }
}

output appserviceId string = appservice.id
