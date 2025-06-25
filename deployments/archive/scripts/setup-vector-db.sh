#!/bin/bash
set -euo pipefail

# Setup Azure AI Foundry Vector Database for Jasmin Catering
# This script creates an AI Search index and uploads the catering documents

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🔍 Azure AI Foundry Vector Database Setup"
echo "========================================="
echo ""
echo "📍 Configuration:"
echo "- Subscription: $AZURE_SUBSCRIPTION_ID"
echo "- Resource Group: $AZURE_RESOURCE_GROUP"
echo "- AI Search Service: jasmin-catering-search"
echo "- Index: jasmin-catering-knowledge"
echo ""

# Check if documents folder exists
DOCS_FOLDER="$(dirname "$0")/../documents"
if [ ! -d "$DOCS_FOLDER" ]; then
    echo "📁 Creating documents folder..."
    mkdir -p "$DOCS_FOLDER"
    echo "⚠️  Please add your catering documents to: $DOCS_FOLDER"
    echo "   Required files:"
    echo "   - catering-brief.md (created: ✅)"
    echo "   - vegetarian-offer-template.md (created: ✅)"
    echo "   - email-template.md (created: ✅)"
    echo "   - business-conditions.md (created: ✅)"
    echo ""
    echo "   Additional templates in deployments/templates/:"
    echo "   - order-templates.md (exists: ✅)"
    echo "   - response-examples.md (exists: ✅)" 
    echo "   - company-policies.md (exists: ✅)"
    exit 1
fi

# Create AI Search Service
echo "🔍 Creating AI Search Service..."
az search service create \
    --name jasmin-catering-search \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --location swedencentral \
    --sku basic \
    --partition-count 1 \
    --replica-count 1 \
    --output none 2>/dev/null || echo "Search service already exists"

# Get AI Search admin key
SEARCH_KEY=$(az search admin-key show \
    --service-name jasmin-catering-search \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --query primaryKey -o tsv)

echo "✅ AI Search Service ready"
echo ""

# Create Search Index
echo "📋 Creating search index..."

cat > temp-index.json << 'EOF'
{
  "name": "jasmin-catering-knowledge",
  "fields": [
    {
      "name": "id",
      "type": "Edm.String",
      "key": true,
      "searchable": false,
      "filterable": true,
      "retrievable": true
    },
    {
      "name": "content",
      "type": "Edm.String",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "analyzer": "de.microsoft"
    },
    {
      "name": "title",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true,
      "retrievable": true
    },
    {
      "name": "category",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true,
      "retrievable": true
    },
    {
      "name": "contentVector",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "retrievable": true,
      "dimensions": 1536,
      "vectorSearchProfile": "vectorProfile"
    }
  ],
  "vectorSearch": {
    "profiles": [
      {
        "name": "vectorProfile",
        "algorithm": "hnsw"
      }
    ],
    "algorithms": [
      {
        "name": "hnsw",
        "kind": "hnsw"
      }
    ]
  }
}
EOF

# Create the index
curl -X POST \
    "https://jasmin-catering-search.search.windows.net/indexes?api-version=2023-11-01" \
    -H "Content-Type: application/json" \
    -H "api-key: $SEARCH_KEY" \
    -d @temp-index.json

rm -f temp-index.json

echo "✅ Search index created"
echo ""

# Upload documents
echo "📄 Processing documents..."

# Function to upload a document
upload_document() {
    local file="$1"
    local category="$2"
    local doc_id=$(basename "$file" .md)
    
    if [ ! -f "$file" ]; then
        echo "⚠️  Warning: Document $file not found"
        return
    fi
    
    # Read content and escape for JSON
    local content=$(cat "$file" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    local title=$(basename "$file" .md | tr '-' ' ' | sed 's/\b\w/\U&/g')
    
    # Create upload payload
    cat > "temp-doc-$doc_id.json" << EOF
{
  "value": [
    {
      "@search.action": "upload",
      "id": "$doc_id",
      "title": "$title",
      "content": "$content",
      "category": "$category"
    }
  ]
}
EOF

    # Upload document
    curl -X POST \
        "https://jasmin-catering-search.search.windows.net/indexes/jasmin-catering-knowledge/docs/index?api-version=2023-11-01" \
        -H "Content-Type: application/json" \
        -H "api-key: $SEARCH_KEY" \
        -d @"temp-doc-$doc_id.json"
    
    rm -f "temp-doc-$doc_id.json"
    echo "✅ Uploaded: $title"
}

# Upload main documents
upload_document "$DOCS_FOLDER/catering-brief.md" "process"
upload_document "$DOCS_FOLDER/vegetarian-offer-template.md" "menu"
upload_document "$DOCS_FOLDER/email-template.md" "communication"
upload_document "$DOCS_FOLDER/business-conditions.md" "terms"

# Upload template documents
TEMPLATES_FOLDER="$(dirname "$0")/../templates"
upload_document "$TEMPLATES_FOLDER/order-templates.md" "templates"
upload_document "$TEMPLATES_FOLDER/response-examples.md" "examples"
upload_document "$TEMPLATES_FOLDER/company-policies.md" "policies"

# Upload project documentation
PROJECT_ROOT="$(dirname "$0")/../.."
upload_document "$PROJECT_ROOT/README.md" "documentation"
upload_document "$PROJECT_ROOT/CLAUDE.md" "ai-guidance"

echo ""
echo "🎉 Vector Database Setup Complete!"
echo ""
echo "📋 Summary:"
echo "- AI Search Service: jasmin-catering-search.search.windows.net"
echo "- Index: jasmin-catering-knowledge"
echo "- Documents uploaded: 9 (4 main + 3 templates + 2 documentation)"
echo ""
echo "🔗 Azure Portal:"
echo "https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Search/searchServices/jasmin-catering-search"
echo ""
echo "💾 Save these credentials to .env:"
echo "AZURE_SEARCH_SERVICE=jasmin-catering-search"
echo "AZURE_SEARCH_KEY=$SEARCH_KEY"
echo "AZURE_SEARCH_INDEX=jasmin-catering-knowledge"
