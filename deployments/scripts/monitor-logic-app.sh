#!/bin/bash

echo "🔍 Monitoring Logic App: jasmin-order-processor-sweden"
echo "📍 Location: Sweden Central"
echo "📧 Monitoring email: ma3u-test@email.de"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo "=================================="

while true; do
    echo ""
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking for new runs..."
    
    # Get latest runs
    az logic workflow run list \
        --resource-group logicapp-jasmin-sweden_group \
        --name jasmin-order-processor-sweden \
        --top 3 \
        --query "[].{RunID:name, Status:status, StartTime:startTime, Trigger:trigger.name}" \
        --output table
    
    # Get latest run details if exists
    LATEST_RUN=$(az logic workflow run list \
        --resource-group logicapp-jasmin-sweden_group \
        --name jasmin-order-processor-sweden \
        --top 1 \
        --query "[0].name" -o tsv)
    
    if [ ! -z "$LATEST_RUN" ]; then
        echo ""
        echo "Latest run details:"
        az logic workflow run show \
            --resource-group logicapp-jasmin-catering_group \
            --name jasmin-order-processor \
            --run-name $LATEST_RUN \
            --query "{Status:status, StartTime:startTime, EndTime:endTime, Duration:duration}" \
            --output table
    fi
    
    echo ""
    echo "Waiting 15 seconds before next check..."
    sleep 15
done