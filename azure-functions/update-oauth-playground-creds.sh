#!/bin/bash

echo "🔄 Updating to OAuth Playground Default Credentials"
echo "================================================="
echo ""
echo "Since your refresh token was obtained using OAuth Playground's default"
echo "credentials, we'll temporarily update your .env to match."
echo ""
echo "Updating .env file..."

# Update .env with OAuth Playground credentials
sed -i.bak 's/GMAIL_CLIENT_ID=.*/GMAIL_CLIENT_ID=407408718192.apps.googleusercontent.com/' .env
sed -i.bak 's/GMAIL_CLIENT_SECRET=.*/GMAIL_CLIENT_SECRET=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/' .env

echo "✅ Updated to OAuth Playground credentials"
echo ""
echo "Testing connection..."
node test-gmail-locally.js