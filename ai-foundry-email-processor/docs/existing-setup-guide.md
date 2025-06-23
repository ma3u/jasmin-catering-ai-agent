# Using Existing Azure Resources - Setup Guide

This guide explains how to deploy the Jasmin Catering order processing system using your existing Azure resources configured in the `.env` file.

## Prerequisites

### Required Azure Resources (from .env)
- Azure Subscription: `b58b1820-35f0-4271-99be-7c84d4dd40f3`
- Resource Group: `logicapp-jasmin-catering_group`
- AI Foundry Project: `jasmin-catering` in `rg-damyandesign-1172`
- Email: `matthias.buchhorn@web.de`

### Required Tools
- Azure CLI (`az`)
- Bash shell
- Text editor

## Step 1: Verify Environment Configuration

```bash
# Navigate to the project directory
cd ai-foundry-email-processor

# Check configuration
./scripts/load-env-config.sh
```

Expected output:
```
✅ Configuration loaded successfully
Using Subscription: b58b1820-35f0-4271-99be-7c84d4dd40f3
Resource Group: logicapp-jasmin-catering_group
AI Project: jasmin-catering
✅ All required configuration variables verified
```

## Step 2: Set Up AI Foundry Agent

Since you already have an AI Foundry project (`jasmin-catering`), we'll add the order processing agent to it:

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Set up the agent
./scripts/setup-agent.sh
```

### Manual Steps in Azure Portal:
1. Go to [Azure AI Studio](https://ai.azure.com)
2. Select your project: `jasmin-catering`
3. Navigate to "Agents" or "Deployments"
4. Create new agent with:
   - Name: `order-processing-agent`
   - Model: `gpt-4o`
   - Upload instructions from `ai-foundry/agent-instructions.txt`
   - Upload knowledge base files from `ai-foundry/knowledge-base/`

## Step 3: Deploy Logic Apps Workflow

Deploy the order processing workflow to your existing resource group:

```bash
./scripts/deploy-workflow.sh
```

This will create a new Logic App called `jasmin-order-processor` in your existing resource group.

## Step 4: Configure API Connections

Set up the necessary API connections:

```bash
./scripts/configure-connections.sh
```

### Manual Authorization Required:
1. Go to Azure Portal > Logic Apps > API Connections
2. For each connection:
   - **webde-imap-connection**: Enter your web.de password
   - **teams-connection**: Sign in with Microsoft account
   - **storage-connection**: Should auto-configure

## Step 5: Update Workflow Parameters

In Azure Portal:
1. Navigate to your Logic App: `jasmin-order-processor`
2. Go to "Logic app designer"
3. Update these parameters:
   - AI Foundry API endpoint from your AI project
   - Teams channel ID for notifications
   - Storage account details

## Step 6: Test the System

### Test with Sample Email:
```bash
# Send test email to: matthias.buchhorn@web.de
# Use one of the sample emails from tests/sample-orders/

# Monitor Logic App runs
az logic workflow run list \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name jasmin-order-processor \
  --output table
```

### Verify Processing:
1. Check Teams channel for approval notification
2. Review draft in storage account
3. Approve/reject via Teams card
4. Verify email response is sent

## Troubleshooting

### Common Issues:

1. **Connection Authorization Failed**
   - Re-authorize in Azure Portal
   - Check credentials in Key Vault

2. **AI Agent Not Responding**
   - Verify AI Foundry endpoint
   - Check API key configuration
   - Review agent deployment status

3. **Email Not Triggering**
   - Verify IMAP connection settings
   - Check email filter criteria
   - Review Logic App trigger history

### Viewing Logs:
```bash
# View recent runs
az logic workflow run show \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name jasmin-order-processor \
  --name <run-id>

# View trigger history
az logic workflow trigger history list \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name jasmin-order-processor \
  --trigger-name "When_a_new_email_arrives"
```

## Next Steps

1. **Production Readiness**:
   - Set up monitoring alerts
   - Configure backup storage
   - Implement error handling

2. **Customization**:
   - Adjust AI prompts in agent instructions
   - Modify response templates
   - Add custom approval logic

3. **Scale Considerations**:
   - Monitor API rate limits
   - Optimize trigger frequency
   - Consider Logic Apps Standard for high volume