# Quick Deployment Checklist

Since your AI agent `jasmin-catering-resource` already exists, here's what you need to do:

## 1. Get Your API Key
```bash
# In Azure Portal:
# 1. Go to: Cognitive Services > jasmin-catering-resource
# 2. Click: Keys and Endpoint
# 3. Copy: Key 1 or Key 2
```

## 2. Test AI Agent (Optional)
```bash
cd ai-foundry-email-processor
./scripts/test-ai-agent.sh YOUR_API_KEY_HERE
```

## 3. Deploy Logic App Workflow

### Option A: Via Azure Portal (Recommended)
1. Go to: https://portal.azure.com
2. Navigate to: `logicapp-jasmin-catering_group` > `mabu-logicapps`
3. Click: "Logic app designer"
4. Switch to: "Code view"
5. Paste content from: `logic-app/order-processing-workflow.json`
6. Replace `@parameters('AIFoundryApiKey')` with your actual API key
7. Save

### Option B: Create Connections First
1. In Azure Portal, go to: API connections
2. Create these connections:
   - **IMAP**: `webde-imap-connection`
     - Server: `imap.web.de`
     - Username: `ma3u-test@email.de`
     - Password: `[Your app password from .env]`
   - **Teams**: `teams-connection`
     - Sign in with Microsoft account

## 4. Update Workflow Parameters
In the Logic App JSON, ensure these are set:
- `"toFilter": "ma3u-test@email.de"`
- `"api-key": "YOUR_ACTUAL_API_KEY"`
- `"uri": "https://jasmin-catering-resource.cognitiveservices.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01"`

## 5. Test Email
Send to: `ma3u-test@email.de`
```
Subject: Catering Anfrage
Body: Ich brauche Catering für 30 Personen
```

## 6. Monitor
```bash
# Check runs
az logic workflow run list \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name mabu-logicapps \
  --output table
```

## Direct Links
- Logic App: https://portal.azure.com/#resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/logicapp-jasmin-catering_group/providers/Microsoft.Logic/workflows/mabu-logicapps
- AI Resource: https://portal.azure.com/#resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/rg-damyandesign-1172/providers/Microsoft.CognitiveServices/accounts/jasmin-catering-resource