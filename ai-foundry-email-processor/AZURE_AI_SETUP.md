# Azure AI Foundry Setup Guide

## Your Current Setup
- **AI Foundry Project**: jasmin-catering
- **Resource**: jasmin-catering-resource
- **Endpoint**: https://jasmin-catering-resource.services.ai.azure.com/api/projects/jasmin-catering
- **API Key**: Stored in .env (ending in ...SOLr)

## Authentication Issue
The API key or endpoint format might need adjustment. Here are the steps to verify:

### 1. Get Correct API Key from Azure Portal

1. Go to [Azure Portal](https://portal.azure.com)
2. Search for "AI Studio" or "Azure AI services"
3. Find your resource: `jasmin-catering-resource`
4. Look for:
   - Keys and Endpoint
   - Access Keys
   - API Keys

### 2. Verify Endpoint Format

The endpoint might be one of these formats:
```
# Option A: AI Services endpoint
https://jasmin-catering-resource.services.ai.azure.com/

# Option B: OpenAI compatible endpoint
https://jasmin-catering-resource.openai.azure.com/

# Option C: Regional endpoint
https://swedencentral.api.cognitive.microsoft.com/
```

### 3. Test Authentication

Once you have the correct endpoint and key, test with:
```bash
# Replace ENDPOINT and API_KEY with your values
curl -X POST "ENDPOINT/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01" \
  -H "api-key: API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }'
```

### 4. Update Logic App Workflow

In the Logic App JSON, update the HTTP action:
```json
"Call_AI_Foundry_Agent": {
  "type": "Http",
  "inputs": {
    "method": "POST",
    "uri": "[YOUR_CORRECT_ENDPOINT]/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01",
    "headers": {
      "Content-Type": "application/json",
      "api-key": "[YOUR_API_KEY]"
    },
    ...
  }
}
```

## Alternative: Use Azure OpenAI Connector

Instead of HTTP action, you might use the Azure OpenAI connector in Logic Apps:

1. In Logic App Designer
2. Add action: "Azure OpenAI"
3. Create connection with:
   - Connection name: `ai-foundry-connection`
   - API Key: Your key
   - Endpoint: Your endpoint
4. Select operation: "Create chat completion"
5. Configure with your prompts

## Need Help?

If you're still having issues:
1. Check if you need to create a deployment first in Azure AI Studio
2. Verify the model name (might be `gpt-4o` or `gpt-4`)
3. Check region availability
4. Ensure your subscription has access to Azure OpenAI

The key information we need:
- Exact endpoint URL from Azure Portal
- Valid API key
- Deployment name (if different from `gpt-4o`)