#!/bin/bash
# Deploy email fixes via Azure Cloud Shell
# Run this script in Azure Cloud Shell or after Docker is running

echo "🚀 Deploying Email Processing Fixes"
echo "==================================="
echo ""
echo "📝 This deployment includes:"
echo "  1. Original customer request in email responses"
echo "  2. UNSEEN email filter to prevent duplicates"
echo "  3. Automatic marking of processed emails"
echo "  4. Skipping of response emails (Re: subjects)"
echo ""

# Configuration
RESOURCE_GROUP="logicapp-jasmin-sweden_group"
REGISTRY_NAME="jasmincateringregistry"
CONTAINER_APP_NAME="jasmin-email-processor"
IMAGE_TAG="email-fix-$(date +%Y%m%d%H%M%S)"

echo "📦 Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Registry: $REGISTRY_NAME"
echo "  Container App: $CONTAINER_APP_NAME"
echo "  Image Tag: $IMAGE_TAG"
echo ""

# Option 1: If running locally with Docker
if command -v docker &> /dev/null && docker info &> /dev/null; then
    echo "🐳 Docker is available. Building image..."
    
    # Build the image
    docker build -t jasmin-catering-ai:$IMAGE_TAG .
    
    # Tag for registry
    docker tag jasmin-catering-ai:$IMAGE_TAG $REGISTRY_NAME.azurecr.io/jasmin-catering-ai:$IMAGE_TAG
    docker tag jasmin-catering-ai:$IMAGE_TAG $REGISTRY_NAME.azurecr.io/jasmin-catering-ai:latest
    
    # Login to ACR
    echo "🔐 Logging into Azure Container Registry..."
    az acr login --name $REGISTRY_NAME
    
    # Push the image
    echo "📤 Pushing image to registry..."
    docker push $REGISTRY_NAME.azurecr.io/jasmin-catering-ai:$IMAGE_TAG
    docker push $REGISTRY_NAME.azurecr.io/jasmin-catering-ai:latest
    
    # Update Container App
    echo "🔄 Updating Container App..."
    az containerapp job update \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --image $REGISTRY_NAME.azurecr.io/jasmin-catering-ai:latest
        
else
    echo "🌩️  Docker not available. Use Azure Cloud Shell:"
    echo ""
    echo "1. Go to: https://portal.azure.com"
    echo "2. Click the Cloud Shell icon (>_) in the top bar"
    echo "3. Clone your repository:"
    echo "   git clone <your-repo-url>"
    echo "   cd jasmin-catering-ai-agent"
    echo ""
    echo "4. Build and push in Cloud Shell:"
    echo "   az acr build --registry $REGISTRY_NAME --image jasmin-catering-ai:$IMAGE_TAG ."
    echo ""
    echo "5. Update Container App:"
    echo "   az containerapp job update \\"
    echo "     --name $CONTAINER_APP_NAME \\"
    echo "     --resource-group $RESOURCE_GROUP \\"
    echo "     --image $REGISTRY_NAME.azurecr.io/jasmin-catering-ai:$IMAGE_TAG"
    echo ""
    echo "Alternative: Manual trigger to test current version:"
    echo "   az containerapp job start \\"
    echo "     --name $CONTAINER_APP_NAME \\"
    echo "     --resource-group $RESOURCE_GROUP"
fi

echo ""
echo "✅ Deployment instructions ready!"
echo ""
echo "📊 Monitor executions:"
echo "   az containerapp job execution list --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --output table"