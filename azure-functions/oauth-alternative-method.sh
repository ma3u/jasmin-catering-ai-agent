#!/bin/bash

echo "🔄 Alternative Method: Using Azure Function OAuth Flow"
echo "===================================================="
echo ""
echo "Since you're getting redirect_uri_mismatch, let's use the Azure Function's"
echo "built-in OAuth flow instead of the OAuth Playground."
echo ""
echo "📋 Step-by-Step Instructions:"
echo ""
echo "1. First, update your Google OAuth client to include Azure Function redirect:"
echo "   Go to: https://console.cloud.google.com/apis/credentials?project=jasmin-catering-logicapp"
echo ""
echo "   Add this redirect URI:"
echo "   ✅ https://jasmin-gmail-functions.azurewebsites.net/api/oauth/callback"
echo ""
echo "2. Let's update the Azure Function to handle OAuth callback:"

# Create OAuth callback function
cat > oauth-callback.js << 'EOF'
const { app } = require('@azure/functions');

app.http('oauthCallback', {
  methods: ['GET'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    const code = request.query.get('code');
    const error = request.query.get('error');
    
    if (error) {
      return {
        status: 400,
        headers: { 'Content-Type': 'text/html' },
        body: `<h1>Authorization Failed</h1><p>Error: ${error}</p>`
      };
    }
    
    if (!code) {
      return {
        status: 400,
        headers: { 'Content-Type': 'text/html' },
        body: '<h1>No authorization code received</h1>'
      };
    }
    
    return {
      status: 200,
      headers: { 'Content-Type': 'text/html' },
      body: `
        <h1>Authorization Successful!</h1>
        <p>Authorization code received. Now exchange it for tokens:</p>
        <pre>
curl -X POST https://jasmin-gmail-functions.azurewebsites.net/api/exchangeToken \\
  -H "Content-Type: application/json" \\
  -d '{"code": "${code}"}'
        </pre>
        <p>Or use this code in the next step: <code>${code}</code></p>
      `
    };
  }
});
EOF

echo ""
echo "3. Alternative: Use the existing LogicApps redirect URIs"
echo "   Since your OAuth client already has these URIs configured:"
echo "   - https://logic-apis-westeurope.consent.azure-apim.net/redirect/gmail"
echo ""
echo "   You can authorize through that URL and then manually get the refresh token."
echo ""
echo "🎯 Quickest Solution: Add OAuth Playground redirect URI"
echo "   This is still the easiest method. In Google Cloud Console, add:"
echo "   https://developers.google.com/oauthplayground"
echo ""
echo "   Then follow the original instructions in setup-gmail-oauth.sh"