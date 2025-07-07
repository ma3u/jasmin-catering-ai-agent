#!/bin/bash
# Check Container Apps logs using Azure Monitor

source deployments/scripts/load-env-config.sh

echo "🔍 Checking Container Apps logs for email processing..."
echo "⏰ Current UTC time: $(date -u '+%Y-%m-%d %H:%M:%S')"

# Get the Log Analytics workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[0].customerId" -o tsv 2>/dev/null)

if [ -z "$WORKSPACE_ID" ]; then
    echo "⚠️  No Log Analytics workspace found"
    echo "📝 Checking Container Apps execution status instead..."
    
    # Show recent executions
    echo -e "\n📊 Recent job executions:"
    az containerapp job execution list \
        --name jasmin-email-processor \
        --resource-group "$RESOURCE_GROUP" \
        --query "[0:5].{Time:startTime,Status:status,Name:name}" \
        --output table
else
    echo "📊 Log Analytics Workspace: $WORKSPACE_ID"
    
    # Query logs for our test email
    echo -e "\n🔎 Searching for test email processing..."
    az monitor log-analytics query \
        --workspace "$WORKSPACE_ID" \
        --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'jasmin-email-processor' | where TimeGenerated > ago(30m) | where Log_s contains 'Test 2025-07-07' or Log_s contains 'Catering Anfrage' | project TimeGenerated, Log_s | order by TimeGenerated desc | take 50" \
        --query "tables[0].rows" \
        --output table 2>/dev/null || echo "❌ Could not query logs"
fi

echo -e "\n💡 Alternative: Check Slack channels for results:"
echo "   - #email-requests-and-response (for email content)"
echo "   - #jasmin-logs (for processing logs)"