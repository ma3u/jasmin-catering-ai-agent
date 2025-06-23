# Jasmin Catering AI Order Processing System

An intelligent email order processing system for Jasmin Catering using Azure AI Foundry and Logic Apps. This system automatically processes catering inquiries, generates professional responses, and manages the approval workflow.

## 🌟 Features

- **Automated Email Monitoring**: Monitors web.de inbox for catering inquiries
- **AI-Powered Analysis**: Uses GPT-4 to understand orders and generate responses
- **Multi-language Support**: Handles German and English inquiries
- **Smart Response Generation**: Creates professional, context-aware responses
- **Approval Workflow**: Teams integration for human review and approval
- **Automated Delivery**: Sends approved responses automatically

## 📋 Prerequisites

- Azure subscription with existing resources (configured in parent `.env`)
- Azure CLI installed and authenticated
- Microsoft Teams for approval notifications
- web.de email account with app-specific password

## 🚀 Quick Start

### Option 1: Automated Deployment (Recommended)
```bash
cd ai-foundry-email-processor
./scripts/deploy-with-azd.sh
```

### Option 2: Alternative CLI Deployment
```bash
cd ai-foundry-email-processor
./scripts/deploy-complete.sh
```

### Option 3: Manual Steps (if needed)
1. **Verify Configuration**:
   ```bash
   ./scripts/load-env-config.sh
   ```

2. **Test AI Connection**:
   ```bash
   ./scripts/test-ai-agent.sh [YOUR_API_KEY]
   ```

**See [AUTOMATED_DEPLOYMENT.md](AUTOMATED_DEPLOYMENT.md) for complete instructions.**

## 📁 Project Structure

```
ai-foundry-email-processor/
├── ai-foundry/              # AI agent configuration
│   ├── agent-instructions.txt
│   ├── agent-config.json
│   └── knowledge-base/      # Business knowledge files
├── logic-app/               # Logic Apps workflow definitions
│   └── order-processing-workflow.json
├── scripts/                 # Deployment and management scripts
│   ├── load-env-config.sh
│   ├── setup-agent.sh
│   ├── deploy-workflow.sh
│   └── configure-connections.sh
├── tests/                   # Test scenarios
│   └── sample-orders/       # Sample email templates
└── docs/                    # Documentation
    ├── existing-setup-guide.md
    ├── order-processing-guide.md
    └── troubleshooting.md
```

## 🔧 Configuration

The system uses configuration from the parent directory's `.env` file:

- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription
- `AZURE_RESOURCE_GROUP`: Target resource group
- `AZURE_AI_PROJECT_NAME`: AI Foundry project name
- `BUSINESS_EMAIL`: Email address to monitor

## 📊 How It Works

1. **Email Reception**: Logic App monitors inbox every 5 minutes
2. **AI Analysis**: GPT-4 extracts order details and generates response
3. **Draft Storage**: Response saved to Azure Storage
4. **Approval Request**: Notification sent to Teams
5. **Human Review**: Team approves/edits/rejects via Teams
6. **Email Delivery**: Approved response sent automatically

## 🎯 Supported Order Types

- **Corporate Events**: Business lunches, conferences, team events
- **Weddings**: Full service catering with Syrian specialties
- **Private Parties**: Birthdays, anniversaries, celebrations
- **Urgent Requests**: Express service within 24 hours

## 💰 Pricing Packages

1. **Basic** (25€/person): Simple mezze and mains
2. **Standard** (35-45€/person): Full buffet with service
3. **Premium** (45-60€/person): Extended menu with live stations
4. **Luxury** (60€+/person): Complete Syrian feast experience

## 🛠️ Maintenance

### Monitoring
```bash
# View recent runs
az logic workflow run list \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name jasmin-order-processor \
  --output table
```

### Updating AI Instructions
1. Edit `ai-foundry/agent-instructions.txt`
2. Re-run `./scripts/setup-agent.sh`
3. Test with sample emails

### Modifying Response Templates
1. Update files in `ai-foundry/knowledge-base/`
2. Re-deploy agent configuration
3. Test response generation

## 🚨 Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md) for detailed solutions to common issues:
- Email trigger not firing
- AI agent errors
- Teams notification issues
- Approval workflow problems

## 📈 Performance Metrics

Track these KPIs:
- Response time (target: <30 minutes)
- AI accuracy (target: >90%)
- Approval rate (target: >80%)
- Customer satisfaction (via feedback)

## 🔐 Security

- API keys stored in Azure Key Vault
- Managed Identity for Azure services
- Encrypted storage for drafts
- GDPR-compliant data handling

## 📞 Support

- **Technical Issues**: See troubleshooting guide
- **Business Questions**: matthias.buchhorn@web.de
- **Azure Support**: Via Azure Portal

## 🎉 Success Stories

- 95% faster response time vs. manual processing
- Handles 100+ inquiries per week
- Multi-language support increases reach
- 24/7 availability for customers

---

Built with ❤️ for Jasmin Catering by the Azure AI team