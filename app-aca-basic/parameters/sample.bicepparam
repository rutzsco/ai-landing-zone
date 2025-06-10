using '../main.bicep'

param environmentName = 'dev-containerapp-env'
param containerAppName = 'dev-container-app'
param location = 'East US'
param containerRegistryLoginServer = 'devcontainerregistry.azurecr.io'
param containerImage = 'myapp:latest'
param targetPort = 80
