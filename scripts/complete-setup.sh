#!/bin/bash

# Complete Automated Setup: Google CLI + LogicApp Deployment
# One command to set up everything!

set -e

echo "🚀 Jasmin Catering AI Agent - Complete Setup"
echo "=============================================="
echo ""
echo "This script will:"
echo "1. 📦 Install Google Cloud CLI (if needed)"
echo "2. 🔑 Set up Google OAuth client app"
echo "3. 🚀 Deploy LogicApp with Gmail + HTTPS Slack integration"
echo "4. 💾 Backup everything to GitHub"
echo ""

read -p "Continue with complete setup? (Y/n): " CONTINUE
if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
    echo "❌ Setup cancelled"
    exit 1
fi

echo ""
echo "🔧 Starting automated setup..."
echo ""

# Step 1: Set up Google CLI and create OAuth client
echo "=============================="
echo "🔑 Step 1: Google OAuth Setup"
echo "=============================="
echo ""

chmod +x scripts/setup-google-cli.sh
./scripts/setup-google-cli.sh

echo ""
echo "=============================="
echo "🚀 Step 2: Deploy LogicApp"
echo "=============================="
echo ""

chmod +x scripts/deploy-automated.sh
./scripts/deploy-automated.sh

echo ""
echo "=============================="
echo "✅ Setup Complete!"
echo "=============================="
echo ""
echo "📋 What was accomplished:"
echo "   ✅ Google Cloud CLI installed and configured"
echo "   ✅ Google OAuth client app created"
echo "   ✅ LogicApp deployed with Gmail trigger"
echo "   ✅ HTTPS Slack webhook integration configured"
echo "   ✅ All configurations backed up to GitHub"
echo ""
echo "🔧 Manual step required:"
echo "   Configure authentication in Azure Portal LogicApp Designer"
echo ""
echo "🧪 Testing:"
echo "   Send email to: mabu.mate@gmail.com"
echo "   Check: #gmail-inbox in mabured.slack.com"
echo ""
echo "🎯 Expected flow:"
echo "   📧 Gmail → LogicApp → HTTPS → Slack ✅"
echo ""
echo "📈 Next phase: Azure AI Foundry integration!"
echo ""
echo "🎉 Jasmin Catering AI Agent is ready!"
