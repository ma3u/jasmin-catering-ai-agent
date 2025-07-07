#!/bin/bash
# Deploy the email format update to Azure Container Apps

set -e

echo "🚀 Deploying Email Format Update"
echo "================================"
echo "This update adds the original customer request to the end of each email response"
echo ""

# Load environment configuration
source deployments/scripts/load-env-config.sh

# Build and push the updated Docker image
echo "🔨 Building Docker image with email format update..."
docker build -t jasmin-catering-ai:email-update .

echo ""
echo "🏷️ Tagging image for Azure Container Registry..."
docker tag jasmin-catering-ai:email-update jasmincateringregistry.azurecr.io/jasmin-catering-ai:email-update
docker tag jasmin-catering-ai:email-update jasmincateringregistry.azurecr.io/jasmin-catering-ai:latest

echo ""
echo "🔐 Logging into Azure Container Registry..."
az acr login --name jasmincateringregistry

echo ""
echo "📤 Pushing updated image to registry..."
docker push jasmincateringregistry.azurecr.io/jasmin-catering-ai:email-update
docker push jasmincateringregistry.azurecr.io/jasmin-catering-ai:latest

echo ""
echo "🔄 Updating Container Apps Job..."
az containerapp job update \
    --name jasmin-email-processor \
    --resource-group "$RESOURCE_GROUP" \
    --image jasmincateringregistry.azurecr.io/jasmin-catering-ai:latest

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 What's new:"
echo "   - Email responses now include the original customer request at the end"
echo "   - Original request shows: sender, date, subject, and full message"
echo "   - Fixed duplicate email processing issue:"
echo "     • Only processes UNSEEN emails"
echo "     • Marks emails as SEEN after processing"
echo "     • Skips response emails (Re: subjects)"
echo "   - Prevents sending multiple responses to the same inquiry"
echo ""
echo "🧪 To test:"
echo "   1. Send a test email to ma3u-test@email.de"
echo "   2. Wait for the next job execution (runs every 5 minutes)"
echo "   3. Check the response email for the original request at the bottom"
echo ""
echo "📊 Monitor job executions:"
echo "   az containerapp job execution list --name jasmin-email-processor --resource-group $RESOURCE_GROUP --output table"