@description('The name of the Cosmos DB account')
param cosmosDbAccountName string

@description('The location for all resources')
param location string = resourceGroup().location

@description('The name of the database')
param databaseName string = 'AgentDatabase'

@description('The name of the collection/container')
param collectionName string = 'ChatHistory'

@description('The partition key for the collection')
param partitionKey string = '/sessionId'

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDbAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosDbAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource collection 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: database
  name: collectionName
  properties: {
    resource: {
      id: collectionName
      partitionKey: {
        paths: [
          partitionKey
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
    }
  }
}

@description('The Cosmos DB account name')
output accountName string = cosmosDbAccount.name

@description('The Cosmos DB endpoint')
output endpoint string = cosmosDbAccount.properties.documentEndpoint

@description('The database name')
output databaseName string = databaseName

@description('The collection name')
output collectionName string = collectionName
