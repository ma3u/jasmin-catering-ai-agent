# OpenAI Assistant Configuration Notes

## Current Situation

The assistant ID `asst_MN5PHipyHYPXyq3fENx7V20j` is referenced in the Logic App workflow but:

1. **Not found** on the current Azure OpenAI resource (`jasmin-catering-resource`)
2. **Assistants API** returns 404 errors, suggesting it might not be enabled
3. **Only gpt-4o** model deployment is available

## Possible Scenarios

### Scenario 1: Different OpenAI Resource
The assistant was created on a different Azure OpenAI resource or OpenAI platform account. You would need:
- The correct endpoint URL where the assistant exists
- Appropriate API key for that resource
- Update the Logic App to use the correct endpoint

### Scenario 2: Use Chat Completions Instead
Since the Assistants API isn't available, you could:
1. Revert to the original `email-processor-workflow.json` that uses Chat Completions
2. Include the full prompt in each request
3. Implement document search separately if needed

### Scenario 3: Enable Assistants API
Contact Azure support to:
1. Enable Assistants API on your Azure OpenAI resource
2. Create the assistant after it's enabled
3. Configure it with the prompt and documents

## Temporary Solution

For now, the Logic App can work with direct Chat Completions API:

```json
{
  "type": "Http",
  "inputs": {
    "method": "POST",
    "uri": "https://jasmin-catering-resource.cognitiveservices.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01",
    "headers": {
      "Content-Type": "application/json",
      "api-key": "@parameters('apiKey')"
    },
    "body": {
      "messages": [
        {
          "role": "system",
          "content": "[Full prompt from jasmin_catering_prompt.md]"
        },
        {
          "role": "user",
          "content": "@{items('Process_Filtered_Emails')['body']}"
        }
      ],
      "temperature": 0.3,
      "max_tokens": 1500
    }
  }
}
```

## Recommendation

1. **Check with your team**: Confirm where assistant `asst_MN5PHipyHYPXyq3fENx7V20j` was created
2. **Use Chat Completions**: For immediate functionality, use the direct API
3. **Future migration**: When Assistants API is available, migrate to use it

## Configuration Files

- **Original workflow**: `email-processor-workflow.json` (uses Chat Completions)
- **Assistant workflow**: `email-processor-assistant-workflow.json` (requires Assistants API)
- **Prompt**: `deployments/documents/jasmin_catering_prompt.md`

You can switch between workflows using:
```bash
# For Chat Completions (working now)
./deployments/scripts/deploy-main.sh

# For Assistants API (when available)
./deployments/scripts/update-to-assistant.sh
```