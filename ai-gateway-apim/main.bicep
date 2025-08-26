targetScope = 'resourceGroup'

@description('The name of the API Management service')
param apiManagementName string

@description('The pricing tier of this API Management service (v2 only)')
@allowed([
  'BasicV2'
  'StandardV2'
])
param sku string = 'BasicV2'

@description('Capacity (scale units). For v2 SKUs, specify 1-10 based on workload.')
param skuCount int = 1

@description('The email address of the owner of the service')
param publisherEmail string

@description('The name of the owner of the service')
param publisherName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Virtual network type')
@allowed([
  'None'
  'External'
  'Internal'
])
param virtualNetworkType string = 'None'

@description('Virtual network configuration')
param virtualNetworkConfiguration object = {}

@description('Tags for the resources')
param tags object = {}

// Identity is fixed to SystemAssigned for this deployment

@description('Custom properties for the API Management service')
param customProperties object = {}

@description('Certificates for the API Management service')
param certificates array = []

@description('Host name configurations for the API Management service')
param hostnameConfigurations array = []

// API Management service (v2) using Azure Verified Module pattern
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apiManagementName
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: !empty(virtualNetworkConfiguration) ? virtualNetworkConfiguration : null
    customProperties: customProperties
    certificates: certificates
    hostnameConfigurations: hostnameConfigurations
  }
  identity: {
  type: 'SystemAssigned'
  }
}

// Diagnostic settings for monitoring
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${apiManagementName}-diagnostics'
  scope: apiManagement
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// Outputs
@description('The resource ID of the API Management service')
output apiManagementResourceId string = apiManagement.id

@description('The name of the API Management service')
output apiManagementName string = apiManagement.name

@description('The gateway URL of the API Management service')
output gatewayUrl string = apiManagement.properties.gatewayUrl

@description('The developer portal URL of the API Management service')
output developerPortalUrl string = apiManagement.properties.developerPortalUrl

@description('The management API URL of the API Management service')
output managementApiUrl string = apiManagement.properties.managementApiUrl

@description('The system assigned identity principal ID')
output systemAssignedIdentityPrincipalId string = apiManagement.identity.principalId

@description('The public IP addresses of the API Management service')
output publicIPAddresses array = apiManagement.properties.publicIPAddresses

@description('The private IP addresses of the API Management service')
output privateIPAddresses array = apiManagement.properties.privateIPAddresses
