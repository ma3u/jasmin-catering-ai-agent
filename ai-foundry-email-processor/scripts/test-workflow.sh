#!/bin/bash

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🧪 Testing Jasmin Catering Order Processing Workflow"
echo "==================================================="

# Function to send test email
send_test_email() {
    local EMAIL_FILE=$1
    local DESCRIPTION=$2
    
    echo ""
    echo "📧 Test: $DESCRIPTION"
    echo "File: $EMAIL_FILE"
    
    # In a real implementation, you would use an SMTP client here
    # For testing, we'll just display what would be sent
    echo "Would send email to: matthias.buchhorn@web.de"
    echo "Content:"
    head -n 20 "$EMAIL_FILE"
    echo "..."
}

# Test 1: Simple Order
send_test_email "../tests/sample-orders/simple-order.eml" "Simple Birthday Party Order"

echo ""
echo "⏳ Waiting 30 seconds for processing..."
sleep 30

# Check Logic App runs
echo ""
echo "📊 Checking Logic App runs..."
RECENT_RUNS=$(az logic workflow run list \
    --resource-group $AZURE_RESOURCE_GROUP \
    --workflow-name jasmin-order-processor \
    --top 5 \
    --query "[].{Name:name, Status:status, StartTime:startTime}" \
    --output table)

echo "$RECENT_RUNS"

# Get the latest run details
LATEST_RUN=$(az logic workflow run list \
    --resource-group $AZURE_RESOURCE_GROUP \
    --workflow-name jasmin-order-processor \
    --top 1 \
    --query "[0].name" -o tsv)

if [ ! -z "$LATEST_RUN" ]; then
    echo ""
    echo "📋 Latest run details:"
    az logic workflow run show \
        --resource-group $AZURE_RESOURCE_GROUP \
        --workflow-name jasmin-order-processor \
        --run-name $LATEST_RUN \
        --query "{Status:status, StartTime:startTime, EndTime:endTime, Error:error}" \
        --output table
fi

echo ""
echo "✅ Test Summary:"
echo "1. Check Teams channel for approval notification"
echo "2. Verify draft was stored in blob storage"
echo "3. Test approve/reject actions in Teams"
echo "4. Confirm email response is sent after approval"

echo ""
echo "🔍 To view detailed logs:"
echo "az logic workflow run show --resource-group $AZURE_RESOURCE_GROUP --workflow-name jasmin-order-processor --run-name $LATEST_RUN"

echo ""
echo "📝 Manual Test Steps:"
echo "1. Send a real test email to: matthias.buchhorn@web.de"
echo "2. Subject should contain: 'Catering' or 'Order'"
echo "3. Monitor Logic App in Azure Portal"
echo "4. Check Teams for notification"
echo "5. Approve/reject in Teams"
echo "6. Verify response email is sent"