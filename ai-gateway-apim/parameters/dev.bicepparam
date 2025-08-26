using '../main.bicep'

// Basic parameters for Azure API Management v2 deployment
param apiManagementName = 'rutzsco-apim-aig-001'
param sku = 'BasicV2'
param skuCount = 1
param publisherEmail = 'scrutz@microsoft.com'
param publisherName = 'Rutzsco AI Gateway'
param location = 'East US 2'
param virtualNetworkType = 'None'
param virtualNetworkConfiguration = {}
param customProperties = {}
param certificates = []
param hostnameConfigurations = []

param tags = {
  Environment: 'Development'
  Project: 'AI Gateway'
}
