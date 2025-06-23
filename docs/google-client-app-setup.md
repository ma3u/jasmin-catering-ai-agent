# 📋 Google Client App Setup Guide

## 🎯 **Goal:** Create Google Client App for "Bring Your Own Application" Authentication

This bypasses ALL Gmail connector restrictions and allows HTTP operations with `mabu.mate@gmail.com`.

---

## 🔧 **Step 1: Create Google Client App**

### **1.1 Open Google API Console**
- **Go to**: [Google API Console Gmail Setup](https://console.developers.google.com/start/api?id=gmail&credential=client_key)
- **Sign in** with your Google account (preferably the same as mabu.mate@gmail.com)

### **1.2 Create/Select Project**
- **Create new project**: `jasmin-catering-logicapp`
- **Or select existing project** if you have one

### **1.3 Enable Gmail API**
- The wizard should automatically enable Gmail API
- **If not**: Go to "APIs & Services" → "Library" → Search "Gmail API" → Enable

### **1.4 Create OAuth 2.0 Credentials**
- **Go to**: "APIs & Services" → "Credentials"
- **Click**: "Create Credentials" → "OAuth client ID"
- **Application type**: "Web application"
- **Name**: "Jasmin Catering LogicApp"

### **1.5 Configure Authorized Redirect URIs**
Add these Azure LogicApp redirect URIs:
```
https://logic-apis-westeurope.consent.azure-apim.net/redirect
https://logic-apis-westeurope.consent.azure-apim.net/redirect/gmail
```

### **1.6 Copy Credentials**
- **Copy Client ID**: (looks like: `123456789-abc...googleusercontent.com`)
- **Copy Client Secret**: (looks like: `GOCSPX-abc123...`)

---

## 🚀 **Step 2: Deploy Workflow**

```bash
cd /Users/ma3u/projects/jasmin-catering-ai-agent
chmod +x scripts/deploy-gmail-custom-auth.sh
./scripts/deploy-gmail-custom-auth.sh
```

**When prompted:**
- **Enter Client ID**: Paste from Google Console
- **Enter Client Secret**: Paste from Google Console

---

## ⚙️ **Step 3: Configure Authentication in LogicApp**

### **3.1 Open LogicApp Designer**
- **Go to**: Azure Portal → LogicApp → Logic app designer

### **3.2 Configure Gmail Trigger**
1. **Click on Gmail trigger** ("When a new email arrives")
2. **Click "Change connection"** or connection settings
3. **Select "Add new"** if needed
4. **Fill in authentication:**
   - **Authentication Type**: `Bring your own application`
   - **Client ID**: Your Google Client ID
   - **Client Secret**: Your Google Client Secret
   - **Login Uri**: `https://accounts.google.com/oauth/authorize`
   - **Tenant**: Leave empty
5. **Click "Sign in"** and authorize with `mabu.mate@gmail.com`

### **3.3 Verify Configuration**
- **Email Address**: Should show `mabu.mate@gmail.com`
- **Connection**: Should show as "Connected"

---

## 🧪 **Step 4: Test Integration**

### **Test Email:**
```
To: mabu.mate@gmail.com
Subject: Test - Custom Auth Integration
Body: Testing Gmail custom authentication with HTTP Slack integration!
```

### **Expected Result:**
- ✅ Email processed by LogicApp
- ✅ HTTPS request sent to Slack webhook  
- ✅ Formatted message in #gmail-inbox channel
- ✅ **No policy violations or restrictions**

---

## 📊 **What This Achieves:**

| Feature | Status | Notes |
|---------|--------|-------|
| **Gmail Support** | ✅ Full | mabu.mate@gmail.com monitored |
| **HTTP Operations** | ✅ Allowed | Custom auth bypasses restrictions |
| **Slack Integration** | ✅ Working | Rich webhook messages |
| **AI Foundry Ready** | ✅ Ready | No connector limitations |
| **Policy Compliant** | ✅ Yes | Microsoft-documented solution |

---

## 🔍 **Troubleshooting:**

### **"App not verified" Warning**
- **Normal behavior** for personal Google apps
- **Click "Advanced"** → "Go to Jasmin Catering LogicApp (unsafe)"
- **Grant permissions**

### **"OAuth Error"**  
- **Check redirect URIs** are exactly as specified
- **Ensure Gmail API** is enabled
- **Try refreshing** the connection

### **Connection Issues**
- **Verify credentials** are correct
- **Check Azure region** matches redirect URI region
- **Try creating new connection**

---

## 📋 **References:**
- **Microsoft Documentation**: [Gmail Connector Security Policy](https://learn.microsoft.com/en-us/azure/connectors/connectors-google-data-security-privacy-policy)
- **Google API Console**: [Gmail API Setup](https://console.developers.google.com)
- **Gmail Connector Docs**: [Authentication Guide](https://docs.microsoft.com/en-us/connectors/gmail/#authentication-and-bring-your-own-application)

**🎉 This solution allows unlimited use of Gmail with HTTP operations - exactly what we need!**
