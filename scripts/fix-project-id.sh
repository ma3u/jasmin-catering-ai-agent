#!/bin/bash

# Quick fix for Google Cloud project ID issue
# This script creates a valid project ID and runs the setup

set -e

echo "🔧 Quick Fix: Google Cloud Project ID Issue"
echo "============================================"
echo ""

# Generate a valid project ID
TIMESTAMP=$(date +%s | tail -c 8)  # Last 7 digits
PROJECT_ID="jasmin-catering-${TIMESTAMP}"

# Validate project ID length and format
echo "📋 Generated Project ID: $PROJECT_ID (${#PROJECT_ID} characters)"

if [ ${#PROJECT_ID} -gt 30 ]; then
    PROJECT_ID="jasmin-cat-${TIMESTAMP}"
    echo "📋 Shortened Project ID: $PROJECT_ID (${#PROJECT_ID} characters)"
fi

if [ ${#PROJECT_ID} -lt 6 ] || [ ${#PROJECT_ID} -gt 30 ]; then
    echo "❌ Error: Project ID validation failed"
    exit 1
fi

if [[ ! "$PROJECT_ID" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "❌ Error: Project ID format validation failed"
    exit 1
fi

echo "✅ Project ID validation passed!"
echo ""

# Test the fixed script
echo "🧪 Testing fixed setup script..."
echo ""

# Run the fixed Google CLI setup
./scripts/setup-google-cli.sh

echo ""
echo "✅ Setup completed successfully!"
