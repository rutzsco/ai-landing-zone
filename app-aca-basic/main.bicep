@description('The name of the Container App Environment')
param environmentName string = 'containerapp-env'

@description('The name of the Container App')
param containerAppName string = 'my-container-app'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The existing container registry login server (e.g., myregistry.azurecr.io)')
param containerRegistryLoginServer string

@description('The container image name and tag')
param containerImage string

@description('The target port for the container')
param targetPort int = 80

module logAnalytics './modules/log-analytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    workspaceName: '${environmentName}-workspace'
    location: location
  }
}

module containerApp './modules/container-app.bicep' = {
  name: 'containerAppDeployment'
  params: {
    environmentName: environmentName
    containerAppName: containerAppName
    location: location
    containerRegistryLoginServer: containerRegistryLoginServer
    containerImage: containerImage
    targetPort: targetPort
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}
