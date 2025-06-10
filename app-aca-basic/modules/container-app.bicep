@description('The name of the Container App Environment')
param environmentName string = 'containerapp-env'

@description('The name of the Container App')
param containerAppName string = 'my-container-app'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The container registry login server')
param containerRegistryLoginServer string

@description('The container image name and tag')
param containerImage string

@description('The target port for the container')
param targetPort int = 80

@description('The Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceId, '2021-06-01').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2021-06-01').primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
      }
      registries: [
        {
          server: containerRegistryLoginServer
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: containerImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

output containerAppUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
