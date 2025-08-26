# Azure API Management Deployment

This folder contains Bicep templates and parameters for deploying Azure API Management instances using Azure Verified Modules patterns.

## Files Structure

```
ai-gateway-apim/
├── main.bicep                    # Main Bicep template for API Management
├── deployment.ipynb             # Jupyter notebook for CLI-based deployment
├── parameters/
│   ├── dev.bicepparam           # Development environment parameters
│   └── prod.bicepparam          # Production environment parameters
└── README.md                    # This file
```

## Features

- **Azure Verified Modules Pattern**: Follows Microsoft's recommended patterns for Bicep modules
- **Multi-Environment Support**: Separate parameter files for different environments
- **Security**: System-assigned managed identity enabled by default
- **Monitoring**: Diagnostic settings configured for logs and metrics
- **Flexible Configuration**: Support for virtual networks, custom domains, and certificates

## Prerequisites

- Azure CLI installed and configured
- Appropriate Azure permissions to create API Management services
- Resource group created (or script will create it)

## Quick Start

### 1. Update Parameters

Edit the parameter files in the `parameters/` folder:
- `dev.bicepparam` - Development environment
- `prod.bicepparam` - Production environment

**Important**: Update the following required parameters:
- `publisherEmail` - Replace with your actual email address
- `publisherName` - Replace with your organization name
- `apiManagementName` - Ensure it's globally unique

### 2. Deploy Using Azure CLI Directly

```bash
# Create resource group (if not exists)
az group create --name "rg-ai-gateway-dev" --location "East US 2"

# Deploy the template
az deployment group create \
  --resource-group "rg-ai-gateway-dev" \
  --template-file "main.bicep" \
  --parameters "parameters/dev.bicepparam"
```

## Configuration Options

### SKU Options (v2)
- **BasicV2**: Small production workloads (v2 platform)
- **StandardV2**: Medium production workloads (v2 platform)

### Virtual Network Integration
To deploy with virtual network integration, update the parameters:

```bicep
param virtualNetworkType = 'External'  // or 'Internal'
param virtualNetworkConfiguration = {
  subnetResourceId: '/subscriptions/.../subnets/apim-subnet'
}
```

### Custom Domains
To configure custom domains, update the `hostnameConfigurations` parameter:

```bicep
param hostnameConfigurations = [
  {
    type: 'Proxy'
    hostName: 'api.contoso.com'
    keyVaultId: '/subscriptions/.../certificates/api-cert'
    certificatePassword: ''
    negotiateClientCertificate: false
  }
]
```

## Outputs

The deployment provides the following outputs:
- `apiManagementResourceId` - Resource ID of the API Management service
- `apiManagementName` - Name of the API Management service
- `gatewayUrl` - Gateway URL for API calls
- `developerPortalUrl` - Developer portal URL
- `managementApiUrl` - Management API URL
- `systemAssignedIdentityPrincipalId` - System-assigned identity principal ID

## Post-Deployment Steps

1. **Configure APIs**: Add your AI/ML APIs to the API Management instance
2. **Set up Products**: Create products to group related APIs
3. **Configure Policies**: Set up authentication, rate limiting, and other policies
4. **Setup Monitoring**: Configure Application Insights for detailed monitoring
5. **Configure Backends**: Set up backend services (Azure OpenAI, etc.)

## Deployment Time

- **BasicV2/StandardV2**: ~30-45 minutes

## Troubleshooting

### Common Issues

1. **Name conflicts**: API Management names must be globally unique
2. **Subscription limits**: Check your subscription limits for API Management instances
3. **Network configuration**: Ensure subnet delegation is configured for VNet integration
4. **Permissions**: Ensure you have `Contributor` role on the resource group

### Useful Commands

```powershell
# Check deployment status
az deployment group show --resource-group "rg-ai-gateway-dev" --name "deployment-name"

# Get API Management properties
az apim show --name "your-apim-name" --resource-group "rg-ai-gateway-dev"

# List all deployments
az deployment group list --resource-group "rg-ai-gateway-dev"
```

## Security Considerations

- System-assigned managed identity is enabled by default
- Consider using Azure Key Vault for certificate management
- Configure appropriate network access controls
- Enable API Management policies for authentication and authorization
- Use Azure Monitor and Application Insights for security monitoring

## Cost Optimization

- Use **Consumption** tier for development and testing
- Monitor usage with Azure Cost Management
- Consider **Basic** tier for small production workloads
- Use **Auto-scale** features in Premium tier for variable loads
