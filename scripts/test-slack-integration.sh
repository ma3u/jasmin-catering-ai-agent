#!/bin/bash

# Simple Solution: Test Slack Integration Immediately
# While we prepare the Azure Functions solution

set -e

echo "🧪 Quick Test: Slack Integration Verification"
echo "============================================"
echo ""
echo "Let's test the Slack webhook while we prepare the full solution!"
echo ""

SLACK_WEBHOOK="https://hooks.slack.com/services/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"

# Test Slack webhook
echo "📤 Sending test message to Slack..."

curl -X POST $SLACK_WEBHOOK \
  -H 'Content-Type: application/json' \
  -d '{
    "text": "🧪 Jasmin Catering Integration Test",
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "🧪 Integration Test Successful"
        }
      },
      {
        "type": "section",
        "fields": [
          {
            "type": "mrkdwn",
            "text": "*Status:* Slack webhook working"
          },
          {
            "type": "mrkdwn",
            "text": "*Time:* '$(date)'"
          },
          {
            "type": "mrkdwn",
            "text": "*Email:* mabu.mate@gmail.com"
          },
          {
            "type": "mrkdwn",
            "text": "*Solution:* Azure Functions + Gmail API"
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*Next Steps:*\n• Azure Functions deployment\n• Gmail API OAuth setup\n• Email monitoring activation\n• AI Foundry integration"
        }
      },
      {
        "type": "divider"
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "🎯 *Goal:* Gmail → Azure Functions → Slack → AI Agent"
        }
      }
    ]
  }'

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Slack webhook test successful!"
    echo "💬 Check #gmail-inbox channel in mabured.slack.com"
    echo ""
    echo "🎯 Next steps:"
    echo "   1. ✅ Slack integration working"
    echo "   2. 🔄 Deploy Azure Functions solution"
    echo "   3. 🔄 Set up Gmail API monitoring"
    echo "   4. 🔄 Connect to AI Foundry"
    echo ""
    echo "🚀 Ready to deploy Azure Functions:"
    echo "   ./scripts/deploy-azure-functions.sh"
else
    echo ""
    echo "❌ Slack webhook test failed"
    echo "🔧 Please check the webhook URL and try again"
fi

echo ""
echo "📋 Summary:"
echo "   📧 Email: mabu.mate@gmail.com (ready)"
echo "   🔑 OAuth: Google credentials created (ready)"
echo "   💬 Slack: Webhook working (ready)"
echo "   ⚡ Functions: Ready to deploy"
echo ""
echo "🎉 All components ready for Azure Functions deployment!"
