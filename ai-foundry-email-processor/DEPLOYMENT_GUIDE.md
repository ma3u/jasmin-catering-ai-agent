# Jasmin Catering AI Order Processing - Deployment Guide

## Current Status
- ✅ Azure AI Foundry Project: `jasmin-catering` (exists in `jasmin-catering-resource`)
- ✅ Logic App: `mabu-logicapps` (exists in `logicapp-jasmin-catering_group`)
- ✅ Email Configuration: `ma3u-test@email.de` with app password
- ⚠️ Region Issue: West Europe not accepting new API connections

## Step-by-Step Deployment

### 1. AI Agent Configuration (Using Existing Agent)

Your AI agent `jasmin-catering-resource` is already created. You just need to:

1. **Go to Azure AI Studio**: https://ai.azure.com
2. **Select your project**: jasmin-catering
3. **Update the existing agent** `jasmin-catering-resource`:
   - Add/Update system prompt with content from: `ai-foundry/agent-instructions.txt`
   - Upload knowledge base files (if not already done):
     - `order-templates.md`
     - `response-examples.md`
     - `company-policies.md`

4. **Your deployment endpoint**:
   ```
   https://jasmin-catering-resource.cognitiveservices.azure.com/
   ```

5. **Get your API Key**:
   - In Azure Portal, go to your Cognitive Services resource
   - Click on "Keys and Endpoint"
   - Copy Key 1 or Key 2

### 2. Logic Apps Workflow Deployment

Since you have an existing Logic App `mabu-logicapps`:

1. **Go to Azure Portal**: https://portal.azure.com
2. **Navigate to**: Resource Groups > `logicapp-jasmin-catering_group` > `mabu-logicapps`
3. **Create new workflow**:
   - Click "Workflows" > "+ Add"
   - Name: `order-processing`
   - Click "Logic app designer"

4. **Switch to Code View** and paste the workflow from:
   ```
   ai-foundry-email-processor/logic-app/order-processing-workflow.json
   ```

5. **Update these values in the JSON**:
   - Replace `@parameters('AIFoundryApiKey')` with your actual API key
   - Replace `@parameters('TeamsChannelId')` with your Teams channel ID
   - Ensure `toFilter` is set to `ma3u-test@email.de`

### 3. API Connections Setup (Manual in Portal)

Due to region restrictions, create connections manually:

1. **Go to**: Logic Apps > API connections
2. **Create IMAP Connection**:
   - Name: `webde-imap-connection`
   - Server: `imap.web.de`
   - Port: `993`
   - Enable SSL: `Yes`
   - Username: `ma3u-test@email.de`
   - Password: `[Your app password from .env]`

3. **Create Teams Connection**:
   - Name: `teams-connection`
   - Sign in with your Microsoft account
   - Authorize access

4. **Create Storage Connection** (if needed):
   - Use existing storage account or create new
   - Name: `storage-connection`

### 4. Update Workflow Connections

After creating connections, update the workflow:

1. In Logic App Designer, click on each connection error
2. Select the appropriate connection you just created
3. Save the workflow

### 5. Test the System

#### Send Test Email:
```
To: ma3u-test@email.de
Subject: Catering Anfrage für Firmenevent
Body:
Guten Tag,
wir benötigen Catering für 50 Personen am 15. Juli 2025.
Mit freundlichen Grüßen
```

#### Monitor Processing:
```bash
# Check Logic App runs
az logic workflow run list \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name mabu-logicapps \
  --output table
```

#### Verify in Teams:
- Check your Teams channel for the approval notification
- Click "Approve & Send" to test the full flow

## Configuration Summary

### Email Settings:
- **Monitored Email**: `ma3u-test@email.de`
- **Keywords**: order, bestell, anfrage, catering, event
- **Check Frequency**: Every 5 minutes

### AI Settings:
- **Endpoint**: `https://jasmin-catering-resource.cognitiveservices.azure.com/`
- **Model**: `gpt-4o`
- **Temperature**: `0.3`
- **Language**: German/English auto-detect

### Response Flow:
1. Email arrives → Filtered by alias and keywords
2. AI analyzes → Generates response draft
3. Teams notification → Human approval
4. Approved → Email sent via SMTP

## Troubleshooting

### Common Issues:

1. **Email not triggering**:
   - Verify exact "To" address matches `ma3u-test@email.de`
   - Check subject contains keywords
   - Ensure IMAP connection is authorized

2. **AI not responding**:
   - Verify API key in Logic App parameters
   - Check AI agent is deployed in AI Studio
   - Test endpoint directly with curl

3. **Teams notification missing**:
   - Verify Teams connection is authorized
   - Check channel ID is correct
   - Ensure bot has access to channel

### Support Links:
- Logic App: https://portal.azure.com/#resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/logicapp-jasmin-catering_group/providers/Microsoft.Logic/workflows/mabu-logicapps
- AI Studio: https://ai.azure.com/project/jasmin-catering
- API Connections: https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fconnections

## Next Steps

1. Complete manual setup in Azure Portal
2. Test with sample emails
3. Monitor for 24 hours
4. Adjust AI prompts based on results
5. Move to production email when ready