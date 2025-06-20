#!/bin/bash

# GitHub Backup Script for Jasmin Catering LogicApp
set -e

# Variables
PROJECT_DIR="/Users/ma3u/projects/jasmin-catering-ai-agent"
GITHUB_REPO="https://github.com/ma3u/jasmin-catering-ai-agent.git"
SUBSCRIPTION_ID="b58b1820-35f0-4271-99be-7c84d4dd40f3"
RESOURCE_GROUP="logicapp-jasmin-catering_group"
LOGIC_APP_NAME="mabu-logicapps"

echo "💾 Starting backup to GitHub..."
echo "📂 Project directory: $PROJECT_DIR"

# Make sure we're in the project directory
cd "$PROJECT_DIR"

# Initialize git repo if needed
if [ ! -d ".git" ]; then
    echo "🔄 Initializing Git repository..."
    git init
    git remote add origin $GITHUB_REPO || echo "Remote origin already exists"
fi

# Create docs directory if it doesn't exist
mkdir -p docs

# Export current LogicApp definition if Azure CLI is available
if command -v az &> /dev/null; then
    echo "📤 Exporting current LogicApp definition..."
    az logicapp show \
      --resource-group $RESOURCE_GROUP \
      --name $LOGIC_APP_NAME \
      --subscription $SUBSCRIPTION_ID > logicapp/current-workflow.json 2>/dev/null || echo "Could not export current workflow (this is normal if not deployed yet)"
fi

# Create configuration backup
echo "📝 Creating configuration files..."
cat > config/azure-resources.json << EOF
{
  "subscription_id": "$SUBSCRIPTION_ID",
  "resource_group": "$RESOURCE_GROUP",
  "logic_app_name": "$LOGIC_APP_NAME",
  "location": "West Europe",
  "gmail_account": "mabu.mate@gmail.com",
  "slack_workspace": "mabured.slack.com",
  "slack_channel": "#gmail-inbox",
  "ai_foundry_project": "https://ai.azure.com/foundryProject/overview?wsid=/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/rg-damyandesign-1172/providers/Microsoft.CognitiveServices/accounts/jasmin-catering-resource/projects/jasmin-catering&tid=6aa73eee-cf67-47a8-8231-d97cdb4b21a0"
}
EOF
# Update README if it doesn't exist
if [ ! -f "README.md" ]; then
echo "📚 Creating README.md..."
cat > README.md << 'EOF'
# Jasmin Catering AI Agent

## 🍽️ Overview
Automated catering inquiry processing system for Jasmin Catering - a Syrian fusion restaurant in Berlin.

## 🤖 Features
- **Email Processing**: Automatic Gmail monitoring for customer inquiries (mabu.mate@gmail.com)
- **Slack Integration**: Real-time notifications to #gmail-inbox in mabured.slack.com
- **AI-Powered Offers**: Generate 3 customized catering packages
- **German Communication**: All customer-facing content in German
- **Azure AI Foundry**: Advanced language processing

## 📧 Email Flow
```
Customer Email → Gmail → LogicApp → Slack → AI Agent → Response
```

## 🚀 Quick Start
1. **Deploy LogicApp**: 
   ```bash
   cd /Users/ma3u/projects/jasmin-catering-ai-agent
   chmod +x scripts/deploy-logicapp.sh
   ./scripts/deploy-logicapp.sh
   ```

2. **Authorize OAuth connections** in Azure Portal (links provided after deployment)

3. **Test** by sending email to mabu.mate@gmail.com

4. **Check** #gmail-inbox channel in mabured.slack.com

## 🏗️ Architecture
- **Azure LogicApps**: Email processing workflow
- **Azure AI Foundry**: Natural language processing  
- **Gmail API**: Email monitoring (mabu.mate@gmail.com)
- **Slack API**: Team notifications (mabured.slack.com)
- **GitHub**: Version control and deployment

## 📋 Business Logic
The AI agent handles Syrian fusion catering requests:
- Finger food and warm meal options
- Vegetarian, vegan, and meat selections
- Guest count (15-500 people)
- Event date and location coordination
- Budget estimation and optimization
- Special dietary requirements

Generated offers include:
- Detailed menu items with authentic pricing
- Professional service personnel
- Equipment rental and setup
- Delivery coordination
- German-language professional formatting

## 🔧 Configuration
- **Azure Resources**: `config/azure-resources.json`
- **Workflow Definition**: `logicapp/workflow-definition.json`  
- **Deployment Scripts**: `scripts/`

## 📚 Documentation
- **Deployment Guide**: `docs/deployment-guide.md`
- **Menu Templates**: Based on Syrian fusion specialties
- **Email Templates**: Professional German correspondence

## 🌟 Key Capabilities
- **Humus with love** - Signature recipe variations
- **Mutabal** - Smoked eggplant specialties  
- **Falafel cups** - Traditional with modern presentation
- **Vegan Kufta** - Mixed vegetable specialties
- **Malakieh desserts** - "The Queen" pistachio treats

## 🎯 Target Events
- Corporate meetings and conferences
- Wedding celebrations
- Private parties and gatherings
- Business lunch catering
- Cultural events and festivals

Serving Berlin with authentic Syrian fusion cuisine! 🇸🇾✨
EOF
fi
# Create deployment guide
if [ ! -f "docs/deployment-guide.md" ]; then
echo "📖 Creating deployment guide..."
cat > docs/deployment-guide.md << 'EOF'
# Jasmin Catering LogicApp Deployment Guide

## Overview
This LogicApp processes incoming emails to mabu.mate@gmail.com and forwards them to Slack channel #gmail-inbox in mabured.slack.com workspace for the Jasmin Catering team.

## Prerequisites
- Azure CLI installed and authenticated
- Access to Azure subscription: `b58b1820-35f0-4271-99be-7c84d4dd40f3`
- Gmail account: `mabu.mate@gmail.com`
- Slack workspace: `mabured.slack.com`
- GitHub repository: `ma3u/jasmin-catering-ai-agent`

## Deployment Steps

### 1. Clone and Setup
```bash
git clone https://github.com/ma3u/jasmin-catering-ai-agent.git
cd jasmin-catering-ai-agent
chmod +x scripts/*.sh
```

### 2. Deploy LogicApp
```bash
./scripts/deploy-logicapp.sh
```

### 3. Authorize OAuth Connections
After deployment, manually authorize in Azure Portal:
- Gmail connection for mabu.mate@gmail.com
- Slack connection for mabured.slack.com

### 4. Test the Flow
- Send test email to mabu.mate@gmail.com
- Verify message appears in #gmail-inbox Slack channel

## Workflow Architecture
```
📧 Gmail (mabu.mate@gmail.com)
    ↓ [Webhook Trigger]
🔄 LogicApp Processing
    ↓ [Parse & Format]
💬 Slack (#gmail-inbox)
    ↓ [Team Notification]
🤖 AI Agent (Future Integration)
```

## Configuration Files
- `logicapp/workflow-definition.json` - Main workflow logic
- `config/azure-resources.json` - Environment configuration
- `scripts/deploy-logicapp.sh` - Automated deployment
- `scripts/backup-to-github.sh` - Version control backup

## Integration Roadmap
1. ✅ Email to Slack forwarding
2. 🔄 AI-powered inquiry parsing  
3. 🔄 Automated offer generation
4. 🔄 German response templates
5. 🔄 Customer follow-up workflows
EOF
fi

# Add timestamp
echo "Last updated: $(date)" > LAST_UPDATED

# Add and commit changes
echo "📤 Preparing Git commit..."
git add .

# Check if there are changes to commit
if [ -n "$(git status --porcelain)" ]; then
    echo "💾 Committing changes..."
    git commit -m "Setup LogicApp: Gmail to Slack forwarding for Jasmin Catering $(date '+%Y-%m-%d %H:%M')"
    
    # Push to GitHub
    echo "🚀 Pushing to GitHub..."
    git push origin main || git push -u origin main
    
    echo "✅ Backup completed successfully!"
else
    echo "ℹ️  No changes to commit."
fi

echo ""
echo "🌐 Repository: $GITHUB_REPO"
echo "📁 Local path: $PROJECT_DIR"
echo "🔗 GitHub: https://github.com/ma3u/jasmin-catering-ai-agent"