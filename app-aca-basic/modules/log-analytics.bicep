@description('The name of the Log Analytics Workspace')
param workspaceName string

@description('The location for the Log Analytics Workspace')
param location string = resourceGroup().location

@description('The SKU for the Log Analytics Workspace')
param sku string = 'PerGB2018'

@description('The retention period in days for the Log Analytics Workspace')
param retentionInDays int = 30

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

output workspaceId string = logAnalyticsWorkspace.id