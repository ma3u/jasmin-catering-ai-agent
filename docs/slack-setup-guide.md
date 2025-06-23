# Slack API Token Setup Guide

This guide will help you create a Slack app and get the API token for the Jasmin Catering Gmail integration.

## Step 1: Create a Slack App

1. **Go to Slack API Portal**
   - Visit: https://api.slack.com/apps
   - Click "**Create New App**"

2. **Choose Creation Method**
   - Select "**From scratch**"
   - App Name: `Jasmin Catering Bot`
   - Pick workspace: `mabured.slack.com`
   - Click "**Create App**"

## Step 2: Configure Bot Permissions

1. **Navigate to OAuth & Permissions**
   - In the left sidebar, click "**OAuth & Permissions**"

2. **Add Bot Token Scopes**
   - Scroll down to "**Scopes**"
   - Under "**Bot Token Scopes**", add these permissions:
     - `chat:write` - Send messages to channels
     - `chat:write.public` - Send messages to channels the bot isn't a member of
     - `channels:read` - View basic channel info
     - `channels:join` - Join public channels

## Step 3: Install App to Workspace

1. **Install the App**
   - Scroll to top of "OAuth & Permissions" page
   - Click "**Install to Workspace**"
   - Review permissions and click "**Allow**"

2. **Copy Bot Token**
   - After installation, you'll see "**Bot User OAuth Token**"
   - It starts with `xoxb-`
   - Copy this token - you'll need it for Azure Functions

## Step 4: Add Bot to Channel

1. **Open Slack**
   - Go to your Slack workspace: `mabured.slack.com`
   - Navigate to `#gmail-inbox` channel

2. **Invite the Bot**
   - Type: `/invite @Jasmin Catering Bot`
   - Or click channel name → "Integrations" → "Add apps" → Select your bot

## Step 5: Configure Azure Functions

### Option 1: Using Azure CLI
```bash
az functionapp config appsettings set \
  --name jasmin-gmail-functions \
  --resource-group jasmin-functions-rg \
  --settings SLACK_TOKEN="xoxb-your-token-here"
```

### Option 2: Using Azure Portal
1. Go to [Azure Portal - Function App Configuration](https://portal.azure.com/#@/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/jasmin-functions-rg/providers/Microsoft.Web/sites/jasmin-gmail-functions/configuration)
2. Click "New application setting"
3. Add:
   - Name: `SLACK_TOKEN`
   - Value: `xoxb-your-token-here`
4. Click "Save"

## Step 6: Test the Integration

### Test Message from Azure Function
Once deployed, the function will automatically send messages to Slack when emails arrive.

### Manual Test with cURL
```bash
curl -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer xoxb-your-token-here" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "gmail-inbox",
    "text": "Test message from Jasmin Catering Bot!"
  }'
```

## Advanced Features (Optional)

### Interactive Messages
To enable buttons and interactive features:

1. **Enable Interactivity**
   - Go to "**Interactivity & Shortcuts**" in app settings
   - Turn on "**Interactivity**"
   - Request URL: `https://jasmin-gmail-functions.azurewebsites.net/api/slackInteractive`
   - Save changes

### Event Subscriptions
For real-time updates:

1. **Enable Events**
   - Go to "**Event Subscriptions**"
   - Turn on "**Enable Events**"
   - Request URL: `https://jasmin-gmail-functions.azurewebsites.net/api/slackEvents`
   - Subscribe to bot events:
     - `message.channels`
     - `app_mention`

## Security Best Practices

1. **Token Storage**
   - Never commit tokens to git
   - Use Azure Key Vault for production
   - Rotate tokens regularly

2. **Permissions**
   - Only grant necessary scopes
   - Use bot tokens, not user tokens
   - Monitor token usage in Slack admin

## Troubleshooting

### Bot can't post to channel
- Ensure bot is invited to `#gmail-inbox`
- Check `chat:write` permission is granted
- Verify channel name in Azure Function settings

### Invalid token error
- Token should start with `xoxb-`
- Ensure no extra spaces when copying
- Verify token hasn't been revoked

### Messages not formatting correctly
- Use Slack Block Kit for rich formatting
- Test in [Block Kit Builder](https://app.slack.com/block-kit-builder)

## Quick Reference

- **Slack API Portal**: https://api.slack.com/apps
- **Your Workspace**: mabured.slack.com
- **Target Channel**: #gmail-inbox
- **Bot Name**: Jasmin Catering Bot
- **Token Format**: xoxb-xxxxxxxxxxxx-xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxx

## Need Help?

- [Slack API Documentation](https://api.slack.com/docs)
- [Bot Users Guide](https://api.slack.com/bot-users)
- [Slack Web API](https://api.slack.com/web)