# Jasmin Catering AI Agent

An intelligent email processing system that automatically responds to catering inquiries using Azure AI services with enhanced RAG (Retrieval Augmented Generation) capabilities and Slack integration.

## 🎯 Current Status

✅ **Fully Deployed and Operational**
- Email processing: `ma3u-test@email.de`
- AI responses with GPT-4o
- RAG system with 4 business documents
- Slack integration for monitoring
- Automated pricing calculations

## 📁 Project Structure

```
jasmin-catering-ai-agent/
├── .env                          # Environment variables (never commit!)
├── CLAUDE.md                     # Guide for future Claude instances
├── README.md                     # This file
├── main.py                       # Main application entry point
│
├── config/                       # Configuration management
│   └── settings.py              # Centralized settings
│
├── core/                        # Core business logic
│   ├── ai_assistant.py          # AI + RAG integration
│   ├── email_processor.py       # Email handling
│   └── slack_notifier.py        # Slack notifications
│
├── deployments/                 # Azure deployment assets
│   ├── scripts/                 # Deployment scripts
│   │   ├── deploy-main.sh      # Main deployment
│   │   ├── load-env-config.sh  # Environment loader
│   │   └── monitor-logic-app.sh # Monitoring
│   ├── logic-apps/             # Workflow definitions
│   └── templates/              # Email templates
│
├── knowledge-base/             # RAG documents
│   └── documents/
│       ├── business-info.md
│       ├── menu-offerings.md
│       ├── pricing-structure.md
│       └── service-policies.md
│
├── rag-system/                 # RAG implementation
│   └── document-indexer.py     # Document upload to Azure AI Search
│
├── scripts/                    # Utility scripts
│   └── (various helper scripts)
│
├── utils/                      # Testing utilities
│   └── send_test_emails.py     # Send test emails
│
└── docs/                       # Documentation
    └── (various guides and reports)
```

## 🚀 Quick Start

### 1. Prerequisites
- Azure subscription
- Python 3.8+
- Azure CLI installed
- Slack workspace (optional)

### 2. Setup
```bash
# Clone repository
git clone https://github.com/yourusername/jasmin-catering-ai-agent.git
cd jasmin-catering-ai-agent

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your credentials
```

### 3. Deploy to Azure
```bash
# Login to Azure
az login

# Deploy all resources
cd deployments/scripts
./deploy-main.sh
```

### 4. Test the System
```bash
# Send test emails
python utils/send_test_emails.py

# Process emails
python main.py
```

## 🏗️ Architecture

### Components
1. **Email Processing**: IMAP/SMTP with web.de
2. **AI Engine**: Azure OpenAI (GPT-4o)
3. **Knowledge Base**: Azure AI Search with 4 documents
4. **Notifications**: Slack integration
5. **Automation**: Azure Logic Apps

### Workflow
```
Customer Email → Email Processor → AI + RAG → Response Generation → Send Reply
                                      ↓
                                Slack Logging
```

## 💰 Pricing System

The AI calculates dynamic pricing based on:
- **Base Packages**: €25-35 (Basis), €35-45 (Standard), €50-70 (Premium)
- **Discounts**: Weekday (10%), Large groups (10%), Nonprofit (10%)
- **Surcharges**: Weekend (+10%), Rush orders (+25%)

See `docs/PRICING_EXPLANATION.md` for details.

## 📊 Features

### Core Features
- ✅ Automated email processing
- ✅ AI-powered response generation
- ✅ RAG for accurate business information
- ✅ Dynamic pricing calculations
- ✅ Slack notifications
- ✅ Multi-language support (German/English)

### Business Logic
- Minimum order: 10 people
- Advance notice: 48 hours
- Service area: Berlin + 50km
- Speciality: Syrian-German fusion cuisine

## 🔧 Configuration

### Environment Variables
All configuration in `.env`:
```env
# Azure
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_AI_API_KEY=your-api-key
AZURE_SEARCH_API_KEY=your-search-key

# Email
FROM_EMAIL_ADDRESS=your-email@web.de
WEBDE_APP_PASSWORD=your-app-password

# Slack
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_CHANNEL_ID=C123456789
```

### Business Settings
Edit `config/settings.py` for:
- Package prices
- Discount rates
- Service areas
- Menu options

## 📱 Slack Integration

### Channels
- `#email-requests-and-response`: Customer communications
- `#jasmin-logs`: System logs and errors

### Setup
1. Create Slack app
2. Get bot token
3. Configure channel IDs
4. See `docs/SLACK_INTEGRATION_GUIDE.md`

## 🧪 Testing

### Send Test Emails
```bash
python utils/send_test_emails.py
```

### Process Emails
```bash
python main.py
```

### Monitor Slack
Check your Slack channels for:
- Email notifications
- AI responses
- System logs

## 🚨 Troubleshooting

### Common Issues

1. **Email not processing**
   - Check email credentials in `.env`
   - Verify email sent TO `ma3u-test@email.de`

2. **AI errors**
   - Verify Azure API key
   - Check endpoint: `https://swedencentral.api.cognitive.microsoft.com`

3. **Slack not working**
   - Verify bot token (starts with xoxb-)
   - Check channel IDs

## 📚 Documentation

- `CLAUDE.md` - Guide for AI assistants
- `docs/PRICING_EXPLANATION.md` - Pricing logic
- `docs/SLACK_INTEGRATION_GUIDE.md` - Slack setup
- `docs/RAG_PROOF_REPORT.md` - RAG system proof

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

This project is proprietary to Jasmin Catering.

## 👥 Team

- **Development**: AI-assisted implementation
- **Client**: Jasmin Catering Berlin
- **Deployment**: Azure Sweden Central

## 🎯 Next Steps

1. **Production Email**: Integrate `info@jasmincatering.com`
2. **Monitoring**: Azure dashboards
3. **Analytics**: Performance tracking
4. **Scaling**: Handle increased volume

---

**Support**: For issues, check `CLAUDE.md` first or contact the development team.