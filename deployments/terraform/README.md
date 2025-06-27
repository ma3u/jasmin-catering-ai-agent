# Terraform Deployment for Jasmin Catering AI Agent

This directory contains Infrastructure as Code (IaC) using Terraform to deploy the Jasmin Catering AI Agent to Azure.

## ⚠️ Status: Alternative Deployment Method

**Current Working Solution**: Shell scripts in `../scripts/`
- ✅ `deploy-main.sh` - Fully functional
- ✅ `deploy-ai-foundry.sh` - AI Foundry specific

**This Terraform**: Alternative IaC approach
- 📋 Complete infrastructure definition
- 🔄 Not actively used but maintained
- 🛠️ Ready for production IaC adoption

## Prerequisites

- Terraform >= 1.0
- Azure CLI installed and authenticated: `az login`
- Azure subscription with appropriate permissions

## Quick Start

1. **Initialize Terraform**
   ```bash
   cd deployments/terraform
   terraform init
   ```

2. **Copy and configure variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your actual values
   ```

3. **Plan the deployment**
   ```bash
   terraform plan
   ```

4. **Apply the configuration**
   ```bash
   terraform apply
   ```

## Architecture

The Terraform configuration deploys:

- **Resource Group**: `logicapp-jasmin-sweden_group` in Sweden Central
- **Logic App Workflow**: Timer-based email processor
- **AI Integration**: Connection to Azure Cognitive Services (GPT-4)

## Important Notes

### Region Restriction
The deployment is configured for **Sweden Central** (`swedencentral`) because West Europe is not accepting new customers. Do not change this location.

### AI Services
The AI Services (Cognitive Services) resource is expected to exist already. This Terraform configuration references it but doesn't create it. Ensure you have:
- AI Services resource: `jasmin-catering-resource`
- Model deployment: `gpt-4o`

### Complete Workflow Definition
The current Terraform configuration provides the basic Logic App structure. For the complete workflow with all actions (email filtering, AI processing, draft creation), you have two options:

1. **Import existing workflow**:
   ```bash
   terraform import azurerm_logic_app_workflow.email_processor \
     /subscriptions/YOUR_SUB_ID/resourceGroups/logicapp-jasmin-sweden_group/providers/Microsoft.Logic/workflows/jasmin-order-processor-sweden
   ```

2. **Deploy using ARM template**:
   Create a file `deployments/terraform/logic_app_template.tf`:
   ```hcl
   resource "azurerm_resource_group_template_deployment" "logic_app_complete" {
     name                = "logic-app-deployment"
     resource_group_name = azurerm_resource_group.main.name
     deployment_mode     = "Incremental"
     
     template_content = file("${path.module}/../logic-apps/email-processor-workflow.json")
     
     parameters_content = jsonencode({
       "workflows_name" = {
         value = var.logic_app_name
       }
       "location" = {
         value = var.location
       }
       "apiKey" = {
         value = var.ai_api_key
       }
     })
   }
   ```

## Outputs

After successful deployment, Terraform will output:
- Resource group details
- Logic App information
- Azure Portal URL for monitoring
- Monitoring command for CLI

## Monitoring

To monitor the deployed Logic App:
```bash
# Using Terraform output
terraform output -raw monitoring_command | bash

# Or directly
az rest --method get \
  --uri "https://management.azure.com/subscriptions/YOUR_SUB_ID/resourceGroups/logicapp-jasmin-sweden_group/providers/Microsoft.Logic/workflows/jasmin-order-processor-sweden/runs?api-version=2019-05-01&\$top=10"
```

## Destroying Resources

To remove all deployed resources:
```bash
terraform destroy
```

## Security Considerations

- Store sensitive values in Azure Key Vault
- Use managed identities instead of API keys where possible
- Enable diagnostic settings for audit logging
- Regularly rotate API keys

## Migration from Shell Scripts

This Terraform configuration provides an alternative to the shell script deployment in `deployments/scripts/`. Benefits include:
- Declarative infrastructure
- State management
- Easy rollback and disaster recovery
- Better collaboration

## Current Production Setup

**Active Logic App**: `jasmin-order-processor-sweden`
**Agent ID**: `asst_xaWmWbwVkjLslHiRrg9teIP0`
**Location**: Sweden Central
**Deployment Method**: Shell scripts (fully functional)

To migrate to Terraform:
1. Import existing resources with `terraform import`
2. Plan changes carefully to avoid service disruption
3. Test thoroughly in non-production environment first