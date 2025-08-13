@description('The name of the Storage Account')
param storageAccountName string

@description('The location for the Storage Account')
param location string = resourceGroup().location

@description('The SKU for the Storage Account')
param skuName string = 'Standard_LRS'

@description('The kind of Storage Account')
param kind string = 'StorageV2'

@description('The access tier for the Storage Account')
param accessTier string = 'Hot'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

@description('The Storage Account name')
output storageAccountName string = storageAccount.name

@description('The Storage Account primary endpoint')
output primaryEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('The Storage Account ID')
output storageAccountId string = storageAccount.id
