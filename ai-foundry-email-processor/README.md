# Jasmin Catering AI Order Processing System

Automated email processing system for Jasmin Catering using Azure Logic Apps and AI Foundry. Processes catering inquiries in German/English and generates intelligent responses.

## 🚀 Current Implementation

- **Email Monitoring**: `ma3u-test@email.de` (web.de alias)
- **AI Processing**: Azure AI Foundry endpoint with GPT-4
- **Location**: North Europe (due to Azure region restrictions)
- **Deployment**: Fully automated CLI deployment - no manual Azure Portal steps

## 📋 Prerequisites

- Azure CLI installed (`brew install azure-cli`)
- Azure subscription access
- Parent `.env` file with all credentials

## 🔧 Quick Deployment

```bash
# Navigate to project
cd ai-foundry-email-processor

# Deploy with Azure CLI
./scripts/deploy-complete.sh
```

This will:
1. Load configuration from parent `.env` file
2. Create Logic App in North Europe
3. Configure email processing workflow
4. Set up AI integration

## 📁 Project Structure

```
ai-foundry-email-processor/
├── scripts/                 # Deployment scripts
│   ├── deploy-complete.sh   # Main deployment script
│   ├── load-env-config.sh   # Environment configuration
│   └── test-ai-agent.sh     # AI connection tester
├── ai-foundry/              # AI agent configuration
│   ├── agent-instructions.txt
│   └── knowledge-base/      # Response templates
├── logic-app/               # Workflow definitions
├── infra/                   # Infrastructure as Code (Bicep)
└── tests/                   # Sample test emails
```

## 🔐 Configuration

All secrets are stored in parent `.env` file:
- `AZURE_AI_ENDPOINT`: AI Foundry endpoint
- `AZURE_AI_API_KEY`: API key (never commit!)
- `WEBDE_EMAIL_ALIAS`: Email to monitor
- `WEBDE_APP_PASSWORD`: Email app password

## 📊 How It Works

1. **Trigger**: Runs every 5 minutes
2. **Email Check**: Monitors `ma3u-test@email.de`
3. **AI Processing**: Analyzes catering inquiries
4. **Response Generation**: Creates professional responses
5. **Logging**: Tracks all processing

## 🛠️ Testing

```bash
# Test AI connection
./scripts/test-ai-agent.sh

# Check deployment status
az logic workflow show \
  --resource-group logicapp-jasmin-catering_group \
  --name jasmin-order-processor \
  --query state

# Monitor runs
az logic workflow run list \
  --resource-group logicapp-jasmin-catering_group \
  --name jasmin-order-processor \
  --output table
```

## 📧 Email Testing

Send test email to: `ma3u-test@email.de`
```
Subject: Catering Anfrage für Firmenevent
Body: Ich brauche Catering für 50 Personen am 15. August in Berlin.
```

## 🌍 Important Notes

- **Region**: Always use `northeurope` (West Europe has restrictions)
- **Security**: Never commit `.env` file
- **API Keys**: Stored only in `.env`, not in code
- **Monitoring**: Check Azure Portal for detailed logs

## 🚨 Troubleshooting

### Region Issues
If deployment fails with "region not accepting customers":
- Use `northeurope` instead of `westeurope`
- Check `AZURE_LOCATION` in scripts

### AI Connection Issues
```bash
# Test endpoint directly
curl -X POST "$AZURE_AI_ENDPOINT/chat/completions?api-version=2024-10-01-preview" \
  -H "api-key: $AZURE_AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Test"}],"max_tokens":50}'
```

### View Logs
```bash
# Get run details
az logic workflow run show \
  --resource-group logicapp-jasmin-catering_group \
  --name jasmin-order-processor \
  --run-name [RUN_ID]
```

## 📈 Next Steps

1. Add IMAP trigger for real email monitoring
2. Implement Teams approval workflow
3. Add email response sending
4. Set up monitoring alerts

## 🔗 Direct Links

- **Logic App**: [Azure Portal](https://portal.azure.com/#resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/logicapp-jasmin-catering_group/providers/Microsoft.Logic/workflows/jasmin-order-processor)
- **AI Project**: [Azure AI Studio](https://ai.azure.com/project/jasmin-catering)

---

Built for Jasmin Catering - Syrian Fusion Cuisine in Berlin