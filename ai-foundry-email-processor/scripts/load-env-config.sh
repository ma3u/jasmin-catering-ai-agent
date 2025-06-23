#!/bin/bash

# Load existing Azure configuration from .env file
if [ -f "../.env" ]; then
    echo "Loading Azure configuration from .env..."
    # Load only valid environment variables (skip comments and invalid lines)
    export $(cat ../.env | grep -E '^[A-Z_]+=.*' | grep -v '^#' | xargs)
    echo "✅ Configuration loaded successfully"
    echo "Using Subscription: $AZURE_SUBSCRIPTION_ID"
    echo "Resource Group: $AZURE_RESOURCE_GROUP"
    echo "AI Project: $AZURE_AI_PROJECT_NAME"
else
    echo "❌ Error: .env file not found in parent directory"
    exit 1
fi

# Set default Azure location if not specified
if [ -z "$AZURE_LOCATION" ]; then
    export AZURE_LOCATION="northeurope"
    echo "ℹ️  Using default location: $AZURE_LOCATION"
fi

# Verify required variables
required_vars=(
    "AZURE_SUBSCRIPTION_ID" 
    "AZURE_RESOURCE_GROUP" 
    "AZURE_AI_PROJECT_NAME"
    "AZURE_AI_RESOURCE_GROUP"
    "BUSINESS_EMAIL"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "❌ Error: Required variables not set in .env:"
    printf '%s\n' "${missing_vars[@]}"
    exit 1
fi

echo "✅ All required configuration variables verified"

# Export additional configuration
export EMAIL_USERNAME="$BUSINESS_EMAIL"
export AI_FOUNDRY_PROJECT_NAME="$AZURE_AI_PROJECT_NAME"
export AI_FOUNDRY_RESOURCE_GROUP="$AZURE_AI_RESOURCE_GROUP"

# Use web.de alias if configured, otherwise fall back to business email
if [ ! -z "$WEBDE_EMAIL_ALIAS" ]; then
    export EMAIL_USERNAME="$WEBDE_EMAIL_ALIAS"
    export EMAIL_PASSWORD="$WEBDE_APP_PASSWORD"
    export IMAP_SERVER="$WEBDE_IMAP_SERVER"
    export SMTP_SERVER="$WEBDE_SMTP_SERVER"
    echo "📧 Using web.de alias: $WEBDE_EMAIL_ALIAS"
else
    export IMAP_SERVER="imap.web.de"
    export SMTP_SERVER="smtp.web.de"
    echo "📧 Email configuration: $EMAIL_USERNAME @ $IMAP_SERVER"
fi

echo "🤖 AI Foundry: $AI_FOUNDRY_PROJECT_NAME in $AI_FOUNDRY_RESOURCE_GROUP"