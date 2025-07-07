#!/bin/bash
# Simple backup of .env to 1Password

echo "🔐 Backing up .env file to 1Password..."

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Create a document item in 1Password
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TITLE="jasmin-catering-env-$TIMESTAMP"

echo "📄 Creating backup as: $TITLE"

# Use op to create a document from the .env file
op document create .env --title="$TITLE" --vault="JasminCatering" --tags="jasmin-catering,env,backup"

if [ $? -eq 0 ]; then
    echo "✅ Successfully backed up .env to 1Password!"
    echo "📍 Vault: JasminCatering"
    echo "📝 Title: $TITLE"
    echo ""
    echo "💡 To retrieve later:"
    echo "   op document get '$TITLE' --vault 'JasminCatering' > .env.restored"
else
    echo "❌ Backup failed. Please ensure you're signed in to 1Password:"
    echo "   eval \$(op signin)"
fi