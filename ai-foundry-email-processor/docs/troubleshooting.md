# Troubleshooting Guide - Jasmin Catering Order Processing

## Common Issues and Solutions

### 1. Email Trigger Not Firing

**Symptoms:**
- No new Logic App runs appearing
- Emails not being processed

**Solutions:**
```bash
# Check trigger history
az logic workflow trigger history list \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name jasmin-order-processor \
  --trigger-name "When_a_new_email_arrives" \
  --output table

# Verify IMAP connection
az resource show \
  --resource-group logicapp-jasmin-catering_group \
  --resource-type "Microsoft.Web/connections" \
  --name "webde-imap-connection" \
  --query "properties.statuses[0]"
```

**Common Fixes:**
- Re-authorize web.de connection in Azure Portal
- Check email password hasn't expired
- Verify IMAP is enabled in web.de settings
- Ensure email matches filter keywords

### 2. AI Agent Not Responding

**Symptoms:**
- HTTP 401/403 errors in Logic App run
- Empty AI response
- Timeout errors

**Solutions:**
1. Verify AI Foundry endpoint:
```bash
# Test AI endpoint
curl -X POST https://jasmin-catering.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01 \
  -H "Content-Type: application/json" \
  -H "api-key: YOUR_API_KEY" \
  -d '{"messages":[{"role":"user","content":"Test"}]}'
```

2. Check API key in Key Vault:
```bash
az keyvault secret show \
  --vault-name jasmin-catering-kv \
  --name ai-foundry-api-key
```

### 3. Teams Notification Not Sending

**Symptoms:**
- Approval notification not appearing in Teams
- Teams connector errors

**Solutions:**
- Re-authenticate Teams connection
- Verify Teams channel ID is correct
- Check Teams permissions for the app
- Test Teams webhook separately

### 4. Storage Access Issues

**Symptoms:**
- Unable to store draft responses
- Permission denied errors

**Solutions:**
```bash
# Check storage account access
az storage account show \
  --name jasmincateringstorage \
  --resource-group logicapp-jasmin-catering_group

# Verify container exists
az storage container list \
  --account-name jasmincateringstorage \
  --query "[?name=='email-drafts']"
```

### 5. Approval Actions Not Working

**Symptoms:**
- Clicking approve/reject in Teams does nothing
- Workflow doesn't continue after approval

**Solutions:**
1. Check Logic App has webhook trigger enabled
2. Verify Teams adaptive card format
3. Ensure callback URL is accessible
4. Check for Logic App timeout settings

## Debugging Tools

### 1. Enable Detailed Logging

In Logic App settings:
```json
{
  "diagnosticSettings": {
    "workflowLogs": "Verbose",
    "engineLogs": "Verbose"
  }
}
```

### 2. View Detailed Run History
```bash
# Get run details
RUN_ID=$(az logic workflow run list \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name jasmin-order-processor \
  --query "[0].name" -o tsv)

# View full run details
az logic workflow run show \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name jasmin-order-processor \
  --run-name $RUN_ID
```

### 3. Test Individual Components

**Test Email Connection:**
```bash
# List recent emails
az rest --method post \
  --uri "https://management.azure.com/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Web/connections/webde-imap-connection/extensions/proxy/testconnection?api-version=2016-06-01"
```

**Test AI Agent:**
Create a test script `test-ai-agent.sh`:
```bash
#!/bin/bash
curl -X POST $AI_FOUNDRY_ENDPOINT \
  -H "Content-Type: application/json" \
  -H "api-key: $AI_API_KEY" \
  -d @tests/sample-orders/simple-order.json
```

## Performance Issues

### Slow Email Processing

**Symptoms:**
- Delays between email receipt and processing
- Timeouts in workflow

**Solutions:**
1. Reduce trigger interval (min 1 minute)
2. Optimize AI prompt for faster responses
3. Use Logic Apps Standard for better performance
4. Implement parallel processing for multiple emails

### High Costs

**Monitor usage:**
```bash
# Check Logic App executions
az consumption usage list \
  --start-date 2025-06-01 \
  --end-date 2025-06-30 \
  --query "[?contains(instanceId, 'jasmin-order-processor')]"
```

**Cost optimization:**
- Adjust trigger frequency
- Implement email filtering
- Use consumption plan wisely
- Archive old runs

## Error Codes Reference

| Error Code | Description | Solution |
|------------|-------------|----------|
| 401 | Unauthorized | Check API keys and permissions |
| 403 | Forbidden | Verify resource access rights |
| 404 | Not Found | Check endpoint URLs |
| 429 | Rate Limited | Implement retry logic |
| 500 | Internal Error | Check service health |
| Timeout | Operation timeout | Increase timeout settings |

## Monitoring Setup

### Create Alerts:
```bash
# CPU usage alert
az monitor metrics alert create \
  --name high-cpu-alert \
  --resource-group logicapp-jasmin-catering_group \
  --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Logic/workflows/jasmin-order-processor" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m

# Failed runs alert
az monitor metrics alert create \
  --name failed-runs-alert \
  --resource-group logicapp-jasmin-catering_group \
  --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Logic/workflows/jasmin-order-processor" \
  --condition "count RunsFailed > 5" \
  --window-size 1h
```

## Emergency Procedures

### System Down:
1. Check Azure service health
2. Verify all connections
3. Restart Logic App
4. Switch to manual processing

### Data Recovery:
1. Access storage account backups
2. Retrieve drafts from blob storage
3. Check Application Insights logs
4. Restore from last known good state

### Rollback Procedure:
```bash
# Export current workflow
az logic workflow export \
  --resource-group logicapp-jasmin-catering_group \
  --name jasmin-order-processor \
  --output-folder ./backup/

# Restore previous version
az logic workflow create \
  --resource-group logicapp-jasmin-catering_group \
  --name jasmin-order-processor \
  --definition "@./backup/previous-version.json"
```

## Support Contacts

- **Azure Support**: Create ticket via Portal
- **Internal IT**: it-support@jasmin-catering.de
- **Developer Team**: dev-team@jasmin-catering.de
- **Business Owner**: matthias.buchhorn@web.de