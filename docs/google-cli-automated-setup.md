# 🚀 Google CLI Automated Setup

## ✅ **Complete Automation with Google Cloud CLI**

This approach uses Google Cloud CLI (`gcloud`) to automatically create the OAuth client app and deploy the LogicApp - no manual web interface needed!

---

## 🎯 **One-Command Setup:**

```bash
cd /Users/ma3u/projects/jasmin-catering-ai-agent
./scripts/complete-setup.sh
```

**This single command will:**
1. ✅ Install Google Cloud CLI (if needed)
2. ✅ Create Google OAuth client app
3. ✅ Deploy LogicApp with Gmail + HTTPS integration
4. ✅ Configure Slack webhook
5. ✅ Backup everything to GitHub

---

## 📋 **Step-by-Step Breakdown:**

### **Option A: Complete Automated Setup**
```bash
# Everything in one command
./scripts/complete-setup.sh
```

### **Option B: Manual Step-by-Step**
```bash
# 1. Install Google Cloud CLI (macOS)
./scripts/install-gcloud-macos.sh

# 2. Set up Google OAuth client
./scripts/setup-google-cli.sh

# 3. Deploy LogicApp
./scripts/deploy-automated.sh
```

---

## 🔧 **What Each Script Does:**

### **`install-gcloud-macos.sh`**
- Installs Homebrew (if needed)
- Installs Google Cloud CLI via Homebrew
- Configures PATH environment variables
- Initializes gcloud components

### **`setup-google-cli.sh`**  
- Authenticates with Google Cloud
- Creates new Google Cloud project
- Enables Gmail API
- Creates OAuth2 client credentials
- Configures redirect URIs for Azure LogicApps
- Saves credentials to `config/google-oauth-credentials.json`

### **`deploy-automated.sh`**
- Reads Google credentials from JSON file
- Creates Azure Gmail connection
- Deploys LogicApp workflow with HTTPS Slack integration
- Uses your existing Slack webhook
- Backs up configuration to GitHub

---

## 📊 **Generated Files:**

```
config/
└── google-oauth-credentials.json    # OAuth client ID and secret

logicapp/
└── gmail-automated-workflow.json    # Complete LogicApp definition

scripts/
├── install-gcloud-macos.sh         # Google CLI installer
├── setup-google-cli.sh             # Google OAuth setup
├── deploy-automated.sh             # LogicApp deployment
└── complete-setup.sh               # One-command setup
```

---

## 🔑 **Authentication Setup (Final Manual Step):**

After running the scripts, complete the setup in Azure Portal:

1. **Open LogicApp Designer:**
   ```
   https://portal.azure.com → LogicApp → Logic app designer
   ```

2. **Configure Gmail Trigger Authentication:**
   - Click Gmail trigger
   - Select "Change connection" 
   - Choose "Add new"
   - **Authentication Type**: `Bring your own application`
   - **Client ID**: (automatically provided from script)
   - **Client Secret**: (automatically provided from script)
   - **Sign in** with `mabu.mate@gmail.com`

3. **Test Integration:**
   ```bash
   # Send test email to: mabu.mate@gmail.com
   # Check: #gmail-inbox in mabured.slack.com
   ```

---

## 🎯 **Expected Workflow:**

```
📧 Gmail (mabu.mate@gmail.com)
    ↓ [Custom Google OAuth - ✅ NO RESTRICTIONS]
🔄 LogicApp Processing
    ↓ [Parse Email Content]
💬 Format Slack Message  
    ↓ [HTTPS Request - ✅ OFFICIALLY SUPPORTED]
📤 Slack Webhook → #gmail-inbox
```

---

## 🔍 **Troubleshooting:**

### **gcloud not found:**
```bash
# Install manually for macOS
./scripts/install-gcloud-macos.sh

# Or install via Homebrew
brew install --cask google-cloud-sdk
```

### **OAuth client creation fails:**
```bash
# Enable required APIs manually
gcloud services enable gmail.googleapis.com
gcloud services enable iam.googleapis.com

# Or create OAuth client in web console
# Script will provide instructions
```

### **LogicApp deployment issues:**
```bash
# Check Azure CLI authentication
az account show

# Verify resource group exists
az group show --name logicapp-jasmin-catering_group
```

---

## 📈 **Advantages of Google CLI Approach:**

- ✅ **Fully Automated**: No manual web interface steps
- ✅ **Reproducible**: Can be re-run or scripted for CI/CD
- ✅ **Version Controlled**: All configuration in code
- ✅ **No Restrictions**: Official Microsoft solution
- ✅ **Professional Setup**: Enterprise-ready deployment
- ✅ **AI Ready**: Perfect for Azure AI Foundry integration

---

## 🎉 **Ready to Deploy!**

```bash
cd /Users/ma3u/projects/jasmin-catering-ai-agent
./scripts/complete-setup.sh
```

**One command. Complete automation. Gmail + HTTPS + Slack integration ready!** 🚀
