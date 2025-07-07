#!/bin/bash
# Backup .env file to 1Password vault

set -e

echo "🔐 1Password .env Backup Script"
echo "================================"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Check if user is signed in to 1Password
if ! op account list >/dev/null 2>&1; then
    echo "📱 Please sign in to 1Password:"
    eval $(op signin)
fi

# Get the vault name
VAULT_NAME="JasminCatering"

echo "📦 Using vault: $VAULT_NAME"

# Read .env file content
ENV_CONTENT=$(cat .env)

# Create timestamp for the item
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Create the 1Password item
echo "🔄 Creating 1Password item..."

# Create a secure note with the .env content
op item create \
    --category="Secure Note" \
    --title="Jasmin Catering .env - $TIMESTAMP" \
    --vault="$VAULT_NAME" \
    --tags="jasmin-catering,env,azure,deployment" \
    notesPlain="$ENV_CONTENT" \
    "backup_date=$TIMESTAMP" \
    "project=jasmin-catering-ai-agent" \
    "environment=production" \
    "azure_region=swedencentral" \
    "purpose=Email processing automation for Jasmin Catering" \
    >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Successfully backed up .env to 1Password!"
    echo "📍 Vault: $VAULT_NAME"
    echo "📝 Title: Jasmin Catering .env - $TIMESTAMP"
    echo ""
    echo "💡 To retrieve this backup later:"
    echo "   op item get 'Jasmin Catering .env - $TIMESTAMP' --vault '$VAULT_NAME' --fields notesPlain"
else
    echo "❌ Failed to create 1Password item"
    exit 1
fi

# Also create a separate item for critical secrets
echo ""
echo "🔑 Creating individual secret entries..."

# Extract key values from .env
while IFS='=' read -r key value; do
    # Skip empty lines and comments
    if [[ -z "$key" || "$key" =~ ^# ]]; then
        continue
    fi
    
    # Remove quotes from value if present
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
    
    # Create entries for critical secrets only
    case "$key" in
        AZURE_SUBSCRIPTION_ID|AZURE_AI_API_KEY|WEBDE_APP_PASSWORD|SLACK_BOT_TOKEN)
            echo "  Adding $key..."
            op item create \
                --category="API Credential" \
                --title="Jasmin Catering - $key" \
                --vault="$VAULT_NAME" \
                --tags="jasmin-catering,azure,api-key" \
                credential="$value" \
                "environment=production" \
                "backup_date=$TIMESTAMP" \
                >/dev/null 2>&1
            ;;
    esac
done < .env

echo ""
echo "🎉 Backup complete!"
echo ""
echo "📋 Summary:"
echo "  - Full .env backup created as Secure Note"
echo "  - Individual entries created for critical secrets"
echo "  - All items stored in vault: $VAULT_NAME"
echo ""
echo "🔍 View items in 1Password:"
echo "   op item list --vault '$VAULT_NAME' --tags 'jasmin-catering'"