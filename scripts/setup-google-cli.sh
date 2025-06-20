#!/bin/bash

# Google Cloud CLI Setup and OAuth Client Creation for Jasmin Catering
# This script automates the entire Google Client App creation process

set -e

echo "🔧 Setting up Google Client App with Google Cloud CLI..."
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "📦 Google Cloud CLI not found. Installing..."
    echo ""
    
    # Detect OS and install gcloud
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            echo "🍺 Installing via Homebrew..."
            brew install --cask google-cloud-sdk
        else
            echo "📥 Please install Homebrew first, or install gcloud manually:"
            echo "   https://cloud.google.com/sdk/docs/install"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo "🐧 Installing via package manager..."
        curl https://sdk.cloud.google.com | bash
        exec -l $SHELL
    else
        echo "❌ Unsupported OS. Please install gcloud manually:"
        echo "   https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    echo "✅ Google Cloud CLI installed!"
    echo ""
fi

# Initialize gcloud if needed
echo "🔐 Checking Google Cloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null 2>&1; then
    echo "🔑 Please authenticate with Google Cloud..."
    gcloud auth login
fi

# Get current authenticated account
GOOGLE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1)
echo "✅ Authenticated as: $GOOGLE_ACCOUNT"
echo ""

# Set project configuration
PROJECT_ID="jasmin-catering-logicapp-$(date +%s)"
PROJECT_NAME="Jasmin Catering LogicApp"

echo "📋 Project Configuration:"
echo "   Project ID: $PROJECT_ID"
echo "   Project Name: $PROJECT_NAME"
echo ""

read -p "Create new project? (Y/n): " CREATE_PROJECT
if [[ ! "$CREATE_PROJECT" =~ ^[Nn]$ ]]; then
    echo "🏗️  Creating Google Cloud project..."
    
    # Create project
    gcloud projects create $PROJECT_ID --name="$PROJECT_NAME"
    
    # Set as current project
    gcloud config set project $PROJECT_ID
    
    # Enable billing (if needed - may require manual setup)
    echo "⚠️  Note: You may need to enable billing for this project in Google Cloud Console"
    echo ""
else
    # Use existing project
    echo "📂 Available projects:"
    gcloud projects list --format="table(projectId,name)"
    echo ""
    read -p "Enter existing project ID: " PROJECT_ID
    gcloud config set project $PROJECT_ID
fi

echo "🔧 Setting up APIs and OAuth client..."

# Enable required APIs
echo "🚀 Enabling Gmail API..."
gcloud services enable gmail.googleapis.com

echo "🚀 Enabling IAM API..."
gcloud services enable iam.googleapis.com

# Create OAuth consent screen configuration
echo "📝 Configuring OAuth consent screen..."

# Note: OAuth consent screen must be configured manually for external users
# But we can set up the client credentials

# Create OAuth2 credentials
echo "🔑 Creating OAuth2 client credentials..."

# Create client secret file
cat > oauth_client_config.json << EOF
{
  "web": {
    "redirect_uris": [
      "https://logic-apis-westeurope.consent.azure-apim.net/redirect",
      "https://logic-apis-westeurope.consent.azure-apim.net/redirect/gmail"
    ],
    "javascript_origins": []
  }
}
EOF

# Create OAuth2 client
OAUTH_CLIENT_OUTPUT=$(gcloud auth application-default set-quota-project $PROJECT_ID 2>/dev/null || true)

# Alternative approach using gcloud alpha commands
if gcloud alpha iam oauth-clients create --help > /dev/null 2>&1; then
    echo "🔑 Creating OAuth client with gcloud alpha commands..."
    
    CLIENT_ID=$(gcloud alpha iam oauth-clients create \
        --display-name="Jasmin Catering LogicApp" \
        --redirect-uris="https://logic-apis-westeurope.consent.azure-apim.net/redirect,https://logic-apis-westeurope.consent.azure-apim.net/redirect/gmail" \
        --format="value(name)" 2>/dev/null || echo "")
    
    if [ -n "$CLIENT_ID" ]; then
        CLIENT_SECRET=$(gcloud alpha iam oauth-clients describe $CLIENT_ID --format="value(secret)")
        echo "✅ OAuth client created successfully!"
    else
        echo "⚠️  Alpha commands not available or failed"
    fi
fi

# Manual instructions if automated creation fails
if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
    echo ""
    echo "📋 Manual OAuth Client Setup Required:"
    echo ""
    echo "1. 🌐 Open Google Cloud Console:"
    echo "   https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
    echo ""
    echo "2. 🔑 Create OAuth Client ID:"
    echo "   - Click 'Create Credentials' → 'OAuth client ID'"
    echo "   - Application type: 'Web application'"
    echo "   - Name: 'Jasmin Catering LogicApp'"
    echo ""
    echo "3. 📝 Add Authorized redirect URIs:"
    echo "   https://logic-apis-westeurope.consent.azure-apim.net/redirect"
    echo "   https://logic-apis-westeurope.consent.azure-apim.net/redirect/gmail"
    echo ""
    echo "4. 📋 Copy Client ID and Client Secret"
    echo ""
    
    read -p "Enter Client ID: " CLIENT_ID
    read -p "Enter Client Secret: " CLIENT_SECRET
fi

# Save credentials for deployment
echo "💾 Saving credentials..."
cat > config/google-oauth-credentials.json << EOF
{
  "project_id": "$PROJECT_ID",
  "client_id": "$CLIENT_ID",
  "client_secret": "$CLIENT_SECRET",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "redirect_uris": [
    "https://logic-apis-westeurope.consent.azure-apim.net/redirect",
    "https://logic-apis-westeurope.consent.azure-apim.net/redirect/gmail"
  ]
}
EOF

echo ""
echo "✅ Google Client App setup completed!"
echo ""
echo "📋 Credentials:"
echo "   Project ID: $PROJECT_ID"
echo "   Client ID: $CLIENT_ID"
echo "   Client Secret: $CLIENT_SECRET"
echo ""
echo "📁 Credentials saved to: config/google-oauth-credentials.json"
echo ""
echo "🚀 Next step: Deploy LogicApp with these credentials"
echo "   Run: ./scripts/deploy-gmail-custom-auth.sh"
echo ""

# Clean up temporary files
rm -f oauth_client_config.json

echo "🎉 Ready for LogicApp deployment!"
