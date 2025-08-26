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

@description('Primary OpenAI backend base URL (e.g., https://<resource>.openai.azure.com)')
param openAiPrimaryBackendUrl string

@description('Secondary OpenAI backend base URL (e.g., https://<resource>-secondary.openai.azure.com)')
param openAiSecondaryBackendUrl string

@description('OpenAPI specification URL for the Azure OpenAI API to import into APIM')
param openAiOpenApiSpecUrl string = 'https://raw.githubusercontent.com/Azure-Samples/ai-hub-gateway-solution-accelerator/refs/heads/main/infra/modules/apim/openai-api/oai-api-spec-2024-10-21.yaml'

@secure()
@description('Primary OpenAI API key (stored securely as an APIM Named Value)')
param openAiPrimaryApiKey string

@secure()
@description('Secondary OpenAI API key (stored securely as an APIM Named Value)')
param openAiSecondaryApiKey string

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

// APIM Backends for OpenAI
resource backendPrimary 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  name: 'openai-primary'
  parent: apiManagement
  properties: {
    url: openAiPrimaryBackendUrl
    protocol: 'http'
    description: 'Primary OpenAI backend'
    // Configure API key at the backend level
    credentials: {
      header: {
        'api-key': [ '{{openai-primary-api-key}}' ]
      }
    }
  }
}

resource backendSecondary 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  name: 'openai-secondary'
  parent: apiManagement
  properties: {
    url: openAiSecondaryBackendUrl
    protocol: 'http'
    description: 'Secondary OpenAI backend'
    // Configure API key at the backend level
    credentials: {
      header: {
        'api-key': [ '{{openai-secondary-api-key}}' ]
      }
    }
  }
}

// Backend pool that load balances across primary and secondary
resource backendPool 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  name: 'openai-pool'
  parent: apiManagement
  properties: any({
    type: 'Pool'
    pool: {
      services: [
        {
          id: backendPrimary.id
          weight: 50
          priority: 1
        }
        {
          id: backendSecondary.id
          weight: 50
          priority: 1
        }
      ]
    }
    description: 'Backend pool for Azure OpenAI (primary + secondary)'
  })
}

// APIM Named Values for OpenAI API keys (stored as secrets)
resource namedValueOpenAiPrimary 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  name: 'openai-primary-api-key'
  parent: apiManagement
  properties: {
    displayName: 'openai-primary-api-key'
    value: openAiPrimaryApiKey
    secret: true
    tags: [ 'openai', 'secret', 'primary' ]
  }
}

resource namedValueOpenAiSecondary 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  name: 'openai-secondary-api-key'
  parent: apiManagement
  properties: {
    displayName: 'openai-secondary-api-key'
    value: openAiSecondaryApiKey
    secret: true
    tags: [ 'openai', 'secret', 'secondary' ]
  }
}

// Azure OpenAI API (imported from OpenAPI spec)
resource openAiApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  name: 'openai-2024-10-21'
  parent: apiManagement
  properties: {
    format: 'openapi-link'
    value: openAiOpenApiSpecUrl
    displayName: 'Azure OpenAI'
    path: 'openai'
    protocols: [ 'https' ]
    subscriptionRequired: false
  }
  dependsOn: [
  backendPool
  ]
}

// Policy using backend pool; API key is configured on the backends
resource openAiApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  name: 'policy'
  parent: openAiApi
  properties: {
    format: 'rawxml'
    value: '''<?xml version="1.0" encoding="utf-8"?>
<policies>
  <inbound>
    <base />
  <set-backend-service backend-id="openai-pool" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>'''
  }
  dependsOn: [ namedValueOpenAiPrimary ]
}

// Diagnostic settings were intentionally omitted in this template. Configure separately if required.

// Outputs
@description('The resource ID of the API Management service')
output apiManagementResourceId string = apiManagement.id

@description('The name of the API Management service')
output apiManagementName string = apiManagement.name

@description('The gateway URL of the API Management service')
output gatewayUrl string = apiManagement.properties.gatewayUrl ?? ''

@description('The developer portal URL of the API Management service')
output developerPortalUrl string = apiManagement.properties.developerPortalUrl ?? ''

@description('The management API URL of the API Management service')
output managementApiUrl string = apiManagement.properties.managementApiUrl ?? ''

@description('The system assigned identity principal ID')
output systemAssignedIdentityPrincipalId string = apiManagement.identity.principalId

@description('The public IP addresses of the API Management service')
output publicIPAddresses array = apiManagement.properties.publicIPAddresses ?? []

@description('The private IP addresses of the API Management service')
output privateIPAddresses array = apiManagement.properties.privateIPAddresses ?? []
