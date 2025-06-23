# 🚀 Jasmin Catering LogicApp Deployment Guide

## 📋 Overview
This guide walks through deploying the LogicApp that processes incoming emails to `mabu.mate@gmail.com` and forwards them to Slack channel `#gmail-inbox` in the `mabured.slack.com` workspace.

---

## 🔧 Prerequisites

### **Required Tools:**
- ✅ **Azure CLI**: Installed and authenticated
- ✅ **Git**: For version control
- ✅ **Terminal/Command Line**: Access to bash scripts

### **Required Accounts & Permissions:**
- ✅ **Azure Subscription**: `b58b1820-35f0-4271-99be-7c84d4dd40f3`
- ✅ **Gmail Account**: `mabu.mate@gmail.com` (accessible)
- ✅ **Slack Workspace**: `mabured.slack.com` (admin access)
- ✅ **GitHub Repository**: `ma3u/jasmin-catering-ai-agent` (write access)

### **Azure Resources:**
- ✅ **Resource Group**: `logicapp-jasmin-catering_group`
- ✅ **LogicApp**: `mabu-logicapps` (existing)
- ✅ **Location**: `West Europe`

---

## 🎯 Step-by-Step Deployment

### **Step 1: Project Setup**
```bash
# Navigate to project directory
cd /Users/ma3u/projects/jasmin-catering-ai-agent

# Verify project structure
ls -la
# Expected: README.md, azure.yaml, scripts/, logicapp/, config/

# Make scripts executable (if not already)
chmod +x scripts/*.sh
```

### **Step 2: Verify Azure Authentication**
```bash
# Check current Azure login
az account show

# Login if needed
az login

# Set correct subscription
az account set --subscription b58b1820-35f0-4271-99be-7c84d4dd40f3

# Verify resource group access
az group show --name logicapp-jasmin-catering_group
```

### **Step 3: Deploy LogicApp Workflow**
```bash
# Run deployment script
./scripts/deploy-logicapp.sh

# The script will:
# ✅ Create Gmail API connection
# ✅ Create Slack API connection  
# ✅ Generate workflow parameters
# ✅ Update LogicApp definition
# ✅ Display authorization links
```

**Expected Output:**
```
🚀 Starting Jasmin Catering LogicApp deployment...
📧 Creating Gmail connection...
💬 Creating Slack connection...
⚙️ Updating LogicApp workflow...
✅ Deployment completed!

🔗 Direct links:
   LogicApp: https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/...
   Gmail Connection: https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/...
   Slack Connection: https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/...
```

### **Step 4: Authorize OAuth Connections** ⚠️ **MANUAL STEP REQUIRED**

1. **Click the Gmail Connection link** from deployment output
2. **Click "Edit API connection"**
3. **Click "Authorize"**
4. **Sign in with `mabu.mate@gmail.com`**
5. **Grant permissions** to Azure LogicApp

6. **Click the Slack Connection link** from deployment output
7. **Click "Edit API connection"**
8. **Click "Authorize"**
9. **Sign in to `mabured.slack.com`**
10. **Grant permissions** to post to channels

### **Step 5: Test the Integration**
```bash
# Send test email to trigger workflow
echo "Send a test email to: mabu.mate@gmail.com"
echo "Subject: Test - Catering Inquiry"
echo "Body: Hello, this is a test inquiry for catering services."

# Check Slack channel
echo "Expected: Message in #gmail-inbox channel within 1-2 minutes"
```

### **Step 6: Backup to GitHub**
```bash
# Run backup script
./scripts/backup-to-github.sh

# This will:
# ✅ Export current LogicApp configuration
# ✅ Update documentation
# ✅ Commit changes to GitHub
# ✅ Push to main branch
```

---

## 🔍 Verification & Testing

### **LogicApp Status Check:**
```bash
# Check LogicApp status
az logicapp show \
  --resource-group logicapp-jasmin-catering_group \
  --name mabu-logicapps \
  --query "{name:name, state:state, location:location}"

# View recent runs
az logicapp run list \
  --resource-group logicapp-jasmin-catering_group \
  --name mabu-logicapps \
  --top 5
```

### **Connection Status Check:**
```bash
# Check Gmail connection
az resource show \
  --resource-group logicapp-jasmin-catering_group \
  --resource-type "Microsoft.Web/connections" \
  --name gmail-mabu-mate

# Check Slack connection  
az resource show \
  --resource-group logicapp-jasmin-catering_group \
  --resource-type "Microsoft.Web/connections" \
  --name slack-mabured
```

### **Test Email Template:**
```
To: mabu.mate@gmail.com
Subject: Wedding Catering Inquiry - March 15, 2025

Hello Jasmin Catering Team,

We are planning a wedding celebration for 120 guests on March 15, 2025, in central Berlin. We would like to request:

- Cocktail hour with finger food (2 hours)
- Main dinner service (vegetarian and meat options)
- Dessert service
- Full beverage service including wine
- Service staff for setup and cleanup

Our budget is approximately €3,500.

Please provide your catering options and availability.

Best regards,
Test Customer
test@example.com
Phone: +49 30 12345678
```

**Expected Slack Message:**
```
📧 New Email for Jasmin Catering
From: test@example.com
Subject: Wedding Catering Inquiry - March 15, 2025
Received: 2025-06-20T15:30:00Z
Email ID: 187abc...

Preview: Hello Jasmin Catering Team, We are planning a wedding celebration for 120 guests...

🤖 Next Steps: This email will be processed by the Jasmin Catering AI Agent for automatic quote generation.
```

---

## 🚨 Troubleshooting

### **Common Issues:**

#### **1. OAuth Authorization Failed**
```bash
# Check connection status
az resource show --resource-group logicapp-jasmin-catering_group --name gmail-mabu-mate

# Symptoms: HTTP 401 errors in LogicApp runs
# Solution: Re-authorize connections in Azure Portal
```

#### **2. LogicApp Not Triggering**
```bash
# Check trigger configuration
az logicapp show --resource-group logicapp-jasmin-catering_group --name mabu-logicapps

# Symptoms: No runs appearing for test emails
# Solution: Verify Gmail IMAP is enabled, check email filters
```

#### **3. Slack Messages Not Appearing**
```bash
# Check Slack connection permissions
# Symptoms: LogicApp runs successfully but no Slack messages
# Solution: Verify #gmail-inbox channel exists, check bot permissions
```

#### **4. Deployment Script Errors**
```bash
# Check Azure CLI authentication
az account show

# Common issues:
# - Wrong subscription selected
# - Insufficient permissions
# - Resource group doesn't exist
```

### **Debug Commands:**
```bash
# View LogicApp run history with details
az logicapp run show \
  --resource-group logicapp-jasmin-catering_group \
  --name mabu-logicapps \
  --run-name [RUN_NAME]

# Check latest workflow definition
az logicapp show \
  --resource-group logicapp-jasmin-catering_group \
  --name mabu-logicapps \
  --query "definition"
```

---

## 🔧 Advanced Configuration

### **Alternative Deployment with azd:**
```bash
# Using Azure Developer CLI
azd auth login
azd init
azd up

# This uses the azure.yaml configuration
```

### **Manual Resource Creation:**
```bash
# If automated deployment fails, create resources manually:

# Gmail connection
az resource create \
  --resource-group logicapp-jasmin-catering_group \
  --resource-type "Microsoft.Web/connections" \
  --name gmail-mabu-mate \
  --location westeurope \
  --properties @gmail-connection.json

# Slack connection
az resource create \
  --resource-group logicapp-jasmin-catering_group \
  --resource-type "Microsoft.Web/connections" \
  --name slack-mabured \
  --location westeurope \
  --properties @slack-connection.json
```

### **Environment Variables:**
```bash
# Set environment variables for scripting
export AZURE_SUBSCRIPTION_ID="b58b1820-35f0-4271-99be-7c84d4dd40f3"
export RESOURCE_GROUP="logicapp-jasmin-catering_group"
export LOGIC_APP_NAME="mabu-logicapps"
export LOCATION="westeurope"
```

---

## 📈 Monitoring & Maintenance

### **Regular Health Checks:**
```bash
# Weekly LogicApp health check
az logicapp run list \
  --resource-group logicapp-jasmin-catering_group \
  --name mabu-logicapps \
  --top 10 \
  --query "[].{status:status, startTime:startTime, name:name}"

# Check for failed runs
az logicapp run list \
  --resource-group logicapp-jasmin-catering_group \
  --name mabu-logicapps \
  --filter "status eq 'Failed'" \
  --top 5
```

### **Backup Schedule:**
```bash
# Set up automated backup (add to cron)
# Run daily at 2 AM
0 2 * * * cd /Users/ma3u/projects/jasmin-catering-ai-agent && ./scripts/backup-to-github.sh
```

### **Performance Optimization:**
- Monitor Slack API rate limits
- Check Gmail API quota usage
- Review LogicApp execution frequency
- Optimize workflow definition for performance

---

## 🎯 Next Steps

### **Immediate (Week 1):**
- ✅ Deploy and test basic email forwarding
- ✅ Verify Slack integration works consistently
- ✅ Set up monitoring and alerts

### **Short Term (Month 1):**
- 🔄 Add Azure AI Foundry agent integration
- 🔄 Create inquiry parsing logic
- 🔄 Build German email templates

### **Medium Term (Month 2-3):**
- 🔄 Implement automated offer generation
- 🔄 Add pricing calculation logic
- 🔄 Test end-to-end customer journey

### **Long Term (Month 3+):**
- 🔄 Migration to production email (info@jasmincatering.com)
- 🔄 Add customer feedback loops
- 🔄 Scale testing and optimization

---

**📞 Support:** For issues or questions, check the [GitHub repository](https://github.com/ma3u/jasmin-catering-ai-agent) or review the main [README.md](../README.md) documentation.
