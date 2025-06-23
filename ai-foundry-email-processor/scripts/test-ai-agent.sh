#!/bin/bash

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🧪 Testing AI Agent Connection"
echo "=============================="
echo "Endpoint: https://$AZURE_AI_SERVICES_ACCOUNT.cognitiveservices.azure.com/"
echo ""

# You'll need to add your API key here or pass it as an argument
if [ -z "$1" ]; then
    echo "Usage: ./test-ai-agent.sh YOUR_API_KEY"
    echo ""
    echo "Get your API key from Azure Portal:"
    echo "1. Go to your Cognitive Services resource"
    echo "2. Click 'Keys and Endpoint'"
    echo "3. Copy Key 1 or Key 2"
    exit 1
fi

API_KEY="$1"

echo "Testing with sample catering inquiry..."
echo ""

# Test the AI endpoint
RESPONSE=$(curl -s -X POST "$AZURE_AI_ENDPOINT/deployments/gpt-4o/chat/completions?api-version=2024-02-01" \
  -H "Content-Type: application/json" \
  -H "api-key: $API_KEY" \
  -d '{
    "messages": [
      {
        "role": "system",
        "content": "You are the Jasmin Catering order processing assistant. Respond in German."
      },
      {
        "role": "user",
        "content": "Ich möchte ein Catering für 30 Personen am 15. August bestellen. Was können Sie mir anbieten?"
      }
    ],
    "temperature": 0.3,
    "max_tokens": 500
  }')

# Check if request was successful
if echo "$RESPONSE" | grep -q "choices"; then
    echo "✅ AI Agent is responding!"
    echo ""
    echo "Response:"
    echo "$RESPONSE" | jq -r '.choices[0].message.content'
else
    echo "❌ Error connecting to AI Agent"
    echo "Response: $RESPONSE"
fi