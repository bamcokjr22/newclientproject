metadata name = 'Log Analytics Module'
metadata description = 'Module used to create log analytics workspace'

@description('Log Analytics Workspace Name')
param workspaceName string
@description('Location of Log Analytics Workspace')
param location string
@description('Log Analytics SKU Name')
param loganalyticsSkuName string

resource loganalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: loganalyticsSkuName
    }
  } 
}

output workspaceId string = loganalytics.id
