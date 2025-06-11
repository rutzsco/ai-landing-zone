using '../main.bicep'

param environmentName = ''
param containerAppName = ''
param location = 'East US'
param containerRegistryLoginServer = 'VALUE.azurecr.io'
param containerRegistryResourceGroupName = ''
param containerImage = 'server.azurecr.io/image:version'
param targetPort = 80
param cosmosDbAccountName = ''
