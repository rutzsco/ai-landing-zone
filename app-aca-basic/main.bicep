@description('The name of the Container App Environment')
param environmentName string = 'containerapp-env'

@description('The name of the Container App')
param containerAppName string = 'my-container-app'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The existing container registry login server (e.g., myregistry.azurecr.io)')
param containerRegistryLoginServer string

@description('The resource group name where the container registry is located')
param containerRegistryResourceGroupName string = resourceGroup().name

@description('The container image name and tag')
param containerImage string

@description('The target port for the container')
param targetPort int = 80

@description('The name of the Cosmos DB account')
param cosmosDbAccountName string = '${environmentName}-cosmos'

@description('Timestamp for unique deployment names')
param deploymentTimestamp string = utcNow()

module logAnalytics './modules/log-analytics.bicep' = {
  name: 'logAnalyticsDeployment-${deploymentTimestamp}'
  params: {
    workspaceName: '${environmentName}-workspace'
    location: location
  }
}

module cosmosDb './modules/cosmos-db.bicep' = {
  name: 'cosmosDbDeployment-${deploymentTimestamp}'
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    location: location
  }
}

module containerApp './modules/container-app.bicep' = {
  name: 'containerAppDeployment-${deploymentTimestamp}'
  params: {
    environmentName: environmentName
    containerAppName: containerAppName
    location: location
    containerRegistryLoginServer: containerRegistryLoginServer
    containerRegistryResourceGroupName: containerRegistryResourceGroupName
    containerImage: containerImage
    targetPort: targetPort
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    cosmosDbEndpoint: cosmosDb.outputs.endpoint
    cosmosDbAccountName: cosmosDb.outputs.accountName
    cosmosDbDatabaseName: cosmosDb.outputs.databaseName
    cosmosDbCollectionName: cosmosDb.outputs.collectionName
  }
}

output containerAppUrl string = containerApp.outputs.containerAppUrl
output cosmosDbEndpoint string = cosmosDb.outputs.endpoint
output cosmosDbAccountName string = cosmosDb.outputs.accountName
output cosmosDbDatabaseName string = cosmosDb.outputs.databaseName
output cosmosDbCollectionName string = cosmosDb.outputs.collectionName
