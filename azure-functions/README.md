# Azure Functions Gmail Integration

This Azure Functions solution bypasses LogicApps Gmail connector restrictions by using direct Gmail API access.

## Why Azure Functions?

The Gmail connector in Azure Logic Apps has strict limitations due to Google's security policies:
- ❌ Blocks HTTP operations
- ❌ Incompatible with Service Bus
- ❌ Cannot use Azure Functions via HTTP
- ❌ Blocks custom APIs and JavaScript operations

**Azure Functions with direct Gmail API solves all these issues:**
- ✅ Full control over OAuth scopes
- ✅ No connector restrictions
- ✅ Direct API calls using Google's Gmail API
- ✅ Can integrate with any Azure service
- ✅ Support for webhooks and real-time notifications

## Architecture

```
Gmail Account (mabu.mate@gmail.com)
    ↓
Gmail API (Direct OAuth)
    ↓
Azure Functions
    ├── Timer Function (polls every 5 min)
    ├── Webhook Function (real-time)
    └── Auth Setup Functions
    ↓
Slack API
    ↓
Slack Channel (#gmail-inbox)
```

## Functions Overview

### 1. **gmailMonitor** (Timer Triggered)
- Runs every 5 minutes
- Polls Gmail for new catering inquiries
- Marks emails as read after processing
- Sends notifications to Slack

### 2. **gmailWebhook** (HTTP Triggered)
- Receives real-time notifications from Gmail
- Processes new emails immediately
- More efficient than polling

### 3. **Auth Setup Functions**
- `getAuthUrl`: Generate OAuth URL for initial setup
- `exchangeToken`: Exchange auth code for refresh token
- `testGmailConnection`: Verify Gmail API connection

## Setup Instructions

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable Gmail API:
   - Go to "APIs & Services" > "Library"
   - Search for "Gmail API"
   - Click "Enable"

### 2. Create OAuth Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Choose "Web application"
4. Add authorized redirect URI:
   ```
   https://developers.google.com/oauthplayground
   ```
5. Save the Client ID and Client Secret

### 3. Get Refresh Token

1. Go to [OAuth Playground](https://developers.google.com/oauthplayground)
2. Click settings (gear icon) and check "Use your own OAuth credentials"
3. Enter your Client ID and Client Secret
4. In Step 1, select:
   - `https://www.googleapis.com/auth/gmail.readonly`
   - `https://www.googleapis.com/auth/gmail.modify`
5. Click "Authorize APIs" and grant permissions
6. Click "Exchange authorization code for tokens"
7. Copy the refresh token

### 4. Create Slack App

1. Go to [Slack API](https://api.slack.com/apps)
2. Create a new app
3. Add OAuth scopes:
   - `chat:write`
   - `chat:write.public`
4. Install to workspace
5. Copy the Bot User OAuth Token

### 5. Deploy Azure Functions

```bash
# Run the deployment script
./scripts/deploy-azure-functions.sh

# After deployment, update settings in Azure Portal:
# - GMAIL_CLIENT_ID
# - GMAIL_CLIENT_SECRET
# - GMAIL_REFRESH_TOKEN
# - SLACK_TOKEN
```

### 6. Set up Gmail Push Notifications (Optional)

For real-time email notifications:

1. Set up Cloud Pub/Sub topic in Google Cloud
2. Configure Gmail to send notifications to the topic
3. Set up push subscription to Azure Function webhook URL

## Local Development

```bash
# Install dependencies
cd azure-functions
npm install

# Install Azure Functions Core Tools
npm install -g azure-functions-core-tools@4

# Run locally
func start
```

## Testing

### Test Gmail Connection
```bash
curl https://your-function-app.azurewebsites.net/api/testGmailConnection
```

### Manual Email Check
```bash
# Trigger the timer function manually
curl -X POST https://your-function-app.azurewebsites.net/admin/functions/gmailMonitor \
  -H "x-functions-key: YOUR_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## Monitoring

View logs in Azure Portal or use CLI:
```bash
func azure functionapp logstream jasmin-catering-functions
```

## Troubleshooting

### "Invalid grant" error
- Refresh token may have expired
- Re-authenticate using OAuth Playground

### No emails being processed
- Check Gmail API quotas in Google Cloud Console
- Verify email filters in gmailMonitor function
- Check Application Insights for errors

### Slack messages not appearing
- Verify Slack token is correct
- Ensure bot has access to the channel
- Check Slack API rate limits