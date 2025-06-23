# Automated Deployment Guide

This guide shows how to deploy the complete Jasmin Catering AI Order Processing system using **only CLI commands** - no Azure Portal configuration required.

## Prerequisites

1. **Azure CLI**: `brew install azure-cli`
2. **Azure Developer CLI**: `brew install azure-dev-cli`
3. **Configuration**: All secrets stored in parent `.env` file

## What Gets Deployed

- ✅ Azure Logic App with complete workflow
- ✅ Storage Account for email drafts
- ✅ API connections with credentials from `.env`
- ✅ AI processing using your existing Azure AI Foundry
- ✅ Email monitoring for `ma3u-test@email.de`

## Option 1: Deploy with Azure Developer CLI (Recommended)

```bash
cd ai-foundry-email-processor
./scripts/deploy-with-azd.sh
```

This will:
1. Load configuration from parent `.env` file
2. Initialize azd environment
3. Deploy infrastructure using Bicep templates
4. Configure Logic App with complete workflow
5. Set up all connections automatically

## Option 2: Deploy with Azure CLI

```bash
cd ai-foundry-email-processor
./scripts/deploy-complete.sh
```

This will:
1. Create resource group if needed
2. Deploy Logic App workflow
3. Create API connections
4. Configure email monitoring

## Configuration Source

All configuration comes from the parent `.env` file:

```bash
# Azure AI Foundry
AZURE_AI_ENDPOINT=https://jasmin-catering-resource.services.ai.azure.com/api/projects/jasmin-catering
AZURE_AI_API_KEY=1cqlnkNqiPHlz7aPqdbW4uWIst2q8WXIjsVk984J5HDLaZKasC3eJQQJ99BEACfhMk5XJ3w3AAAAACOGSOLr

# Email Configuration
WEBDE_EMAIL_ALIAS=ma3u-test@email.de
WEBDE_APP_PASSWORD=EVLKOLKSZ2QYVMNYFU7D

# Azure Subscription
AZURE_SUBSCRIPTION_ID=b58b1820-35f0-4271-99be-7c84d4dd40f3
AZURE_RESOURCE_GROUP=logicapp-jasmin-catering_group
```

## Verification

After deployment, verify everything works:

```bash
# Check Logic App status
az logic workflow show \
  --resource-group logicapp-jasmin-catering_group \
  --name jasmin-order-processor \
  --query state

# Send test email to: ma3u-test@email.de
# Subject: "Catering Anfrage für Test"
# Body: "Ich brauche Catering für 20 Personen"

# Check workflow runs
az logic workflow run list \
  --resource-group logicapp-jasmin-catering_group \
  --name jasmin-order-processor \
  --output table
```

## What's Automated

### ✅ Completely Automated
- Resource group creation
- Logic App deployment
- Storage account setup
- Workflow configuration
- AI endpoint integration
- Email trigger configuration
- Credential management from `.env`

### ⚠️ May Require Manual Steps (Due to Region Restrictions)
If you get region restriction errors:
- API connections might need to be created in a different region
- Some OAuth connections may require one-time authorization

### 🔍 Troubleshooting

**Region Restrictions:**
```bash
# Try different region
export AZURE_LOCATION="northeurope"
./scripts/deploy-with-azd.sh
```

**Check Deployment Status:**
```bash
# azd deployment
azd monitor --environment production

# CLI deployment
az deployment group list --resource-group logicapp-jasmin-catering_group
```

**Test AI Endpoint:**
```bash
./scripts/test-ai-agent.sh
```

## Security

- ✅ No secrets in code or templates
- ✅ All credentials from `.env` file
- ✅ `.env` is gitignored
- ✅ Azure Key Vault integration ready
- ✅ Secure parameter passing

## Cleanup

```bash
# Delete everything
az group delete --name logicapp-jasmin-catering_group --yes

# Or with azd
azd down --environment production
```