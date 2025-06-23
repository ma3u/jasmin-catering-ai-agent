# 🔑 How to Get Your Slack Bot Token

## 📱 **Step 1: Access Your Slack App**

Your Slack app details:
- **App Name**: YasminCatering  
- **App ID**: A0931KMSEEL
- **Workspace**: mabured.slack.com

**🔗 Direct Link**: https://api.slack.com/apps/A0931KMSEEL

## 🔐 **Step 2: Get Bot User OAuth Token**

1. **Go to OAuth & Permissions** in your app settings
   - Click "OAuth & Permissions" in the left sidebar
   
2. **Find Bot User OAuth Token**
   - Look for section "OAuth Tokens for Your Workspace"
   - Copy the **Bot User OAuth Token**
   - It starts with `xoxb-`

3. **Required Scopes** (should already be set):
   - ✅ `chat:write` - Send messages as the bot
   - ✅ `chat:write.public` - Send messages to public channels

## 💻 **Step 3: Configure Your Environment**

### **For Local Testing:**
```bash
# In your terminal
export SLACK_TOKEN=xoxb-your-actual-bot-token-here
export SLACK_CHANNEL=gmail-inbox
```

### **For Azure Functions:**
Add to Function App Settings:
```bash
az functionapp config appsettings set \
  --name jasmin-gmail-functions \
  --resource-group jasmin-functions-rg \
  --settings SLACK_TOKEN=xoxb-your-actual-bot-token-here
```

## 🤖 **Step 4: Add Bot to Channel**

1. **Go to #gmail-inbox** in your Slack workspace
2. **Invite the bot** by typing:
   ```
   /invite @YasminCatering
   ```
3. **Confirm the bot appears** in the channel member list

## 🧪 **Step 5: Test the Integration**

### **Quick Test:**
```bash
cd azure-functions
export SLACK_TOKEN=xoxb-your-token
node test-slack-integration.js
```

### **Full Integration Test:**
```bash
export SLACK_TOKEN=xoxb-your-token
./test-azure-integration.sh
```

## 🚨 **Troubleshooting**

### **"invalid_auth" Error**
- ❌ Wrong token format
- ✅ Should start with `xoxb-`
- ✅ Copy from "Bot User OAuth Token" section

### **"channel_not_found" Error**  
- ❌ Bot not in channel
- ✅ Type `/invite @YasminCatering` in #gmail-inbox

### **"not_authed" Error**
- ❌ Token not set or expired
- ✅ Regenerate token in Slack app settings

### **"missing_scope" Error**
- ❌ Missing required permissions
- ✅ Add `chat:write` and `chat:write.public` scopes

## 📋 **Token Security**

⚠️ **Important Security Notes:**
- Never commit tokens to Git repositories
- Use environment variables for local development
- Store in Azure Function App Settings for production
- Regenerate tokens if compromised

## ✅ **Success Indicators**

You know it's working when:
1. ✅ `node test-slack-integration.js` shows "✅ Slack API Connection Success"
2. ✅ Test message appears in #gmail-inbox channel
3. ✅ Bot shows as member of #gmail-inbox channel
4. ✅ Rich message formatting works (blocks, buttons)

## 🔗 **Next Steps**

Once Slack is working:
1. **Test Gmail integration**: Send email to mabu.mate@gmail.com
2. **Check Azure Functions**: Verify functions are processing emails
3. **Monitor logs**: Watch for processing messages in Azure
4. **Production test**: Send real catering inquiry

---

**🇸🇾 Ready to serve Berlin with Syrian fusion cuisine! ✨**
