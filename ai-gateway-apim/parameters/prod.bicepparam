using '../main.bicep'

// Production parameters for Azure API Management v2 deployment
param apiManagementName = 'apim-ai-gateway-prod-001'
param sku = 'StandardV2'
param skuCount = 1
param publisherEmail = 'admin@contoso.com'
param publisherName = 'Contoso AI Gateway'
param location = 'East US 2'
param virtualNetworkType = 'None'
param virtualNetworkConfiguration = {}
param customProperties = {}
param certificates = []
param hostnameConfigurations = []

// OpenAI backend endpoints
param openAiPrimaryBackendUrl = 'https://contoso-openai-eastus.openai.azure.com'
param openAiSecondaryBackendUrl = 'https://contoso-openai-centralus.openai.azure.com'

// Secure API keys (supply securely via CLI/Env; empty by default)
@secure()
param openAiPrimaryApiKey = ''
@secure()
param openAiSecondaryApiKey = ''

param tags = {
  Environment: 'Production'
  Project: 'AI Gateway'
  Owner: 'Platform Team'
  CostCenter: 'IT'
}
