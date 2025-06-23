# Claude Code Implementation Prompt: Azure AI Foundry + Logic Apps Email Order Processing

## TASK OVERVIEW
Implement a comprehensive Azure AI Foundry + Logic Apps system for processing order emails from matthias.buchhorn@web.de. **Use the existing Azure configuration from the .env file** instead of creating new resources. Focus on deploying the Logic Apps workflow and AI Foundry agent integration using the pre-configured Azure environment.

**Important**: The user already has Azure resources configured in `.env` - use these existing resources for deployment.

**Architecture**: IMAP → AI Foundry Agent → Draft Storage → Approval Workflow → SMTP Delivery

**Key Workflow**:
1. 📧 Receive order email from web.de/1und1
2. 🤖 Send to Azure AI Foundry Agent for analysis
3. 📝 Agent generates response draft and stores in postbox
4. 🔔 Send approval notification
5. ✅ After approval, send final email via SMTP

## PROJECT STRUCTURE TO CREATE
```
ai-foundry-email-processor/
├── .env (already exists - your Azure configuration)
├── README.md (already created)
├── scripts/
│   ├── deploy-workflow.sh (uses existing .env)
│   ├── setup-agent.sh (uses existing AI Foundry)
│   ├── configure-connections.sh (uses existing resources)
│   └── test-workflow.sh
├── ai-foundry/
│   ├── agent-instructions.txt
│   ├── agent-config.json
│   ├── knowledge-base/
│   │   ├── order-templates.md
│   │   ├── response-examples.md
│   │   └── company-policies.md
│   └── tools/
│       ├── order-parser.py
│       └── draft-generator.py
├── logic-app/
│   ├── order-processing-workflow.json
│   ├── parameters.json (references .env variables)
│   ├── connections.json (uses existing resources)
│   └── approval-workflow.json
├── config/
│   ├── load-env-config.sh
│   ├── email-settings.json (populated from .env)
│   ├── agent-prompts.json
│   ├── approval-rules.json
│   └── connection-templates/ (for existing resources)
├── tests/
│   ├── sample-orders/
│   │   ├── simple-order.eml
│   │   ├── complex-order.eml
│   │   └── german-order.eml
│   ├── expected-drafts/
│   └── workflow-tests.json
└── docs/
    ├── existing-setup-guide.md
    ├── order-processing-guide.md
    └── troubleshooting.md
```

## DETAILED IMPLEMENTATION REQUIREMENTS

### 1. Azure AI Foundry Agent Setup (`ai-foundry/`)

#### Agent Instructions (`agent-instructions.txt`)
Create comprehensive instructions for the order processing agent:
```
You are a professional order processing assistant for a German business. 

Your primary responsibilities:
1. Analyze incoming order emails in German or English
2. Extract key order details (products, quantities, customer info, delivery requirements)
3. Generate professional response drafts in the appropriate language
4. Flag any missing information or special requirements
5. Suggest appropriate next steps and follow-up actions

Response Style:
- Professional and courteous tone
- Include order confirmation details
- Mention delivery timeframes
- Request any missing information politely
- Follow German business communication standards

Always structure your responses with:
- Greeting and acknowledgment
- Order summary and confirmation
- Next steps and timeline
- Contact information for questions
```

#### Agent Configuration (`agent-config.json`)
```json
{
  "name": "order-processing-agent",
  "description": "Processes order emails and generates response drafts",
  "model": "gpt-4",
  "instructions_file": "agent-instructions.txt",
  "tools": [
    {
      "type": "code_interpreter",
      "enabled": true
    },
    {
      "type": "file_search",
      "enabled": true,
      "vector_store_ids": ["order-knowledge-base"]
    }
  ],
  "temperature": 0.3,
  "top_p": 1.0,
  "response_format": "auto"
}
```

#### Knowledge Base Files (`knowledge-base/`)
**order-templates.md**: Standard response templates
**response-examples.md**: Example responses for different order types
**company-policies.md**: Business rules and policies for order processing

### 2. Logic Apps Workflow (`logic-app/order-processing-workflow.json`)

Create a comprehensive workflow with these components:

#### A. Email Trigger (IMAP)
```json
{
  "trigger": {
    "type": "ApiConnection",
    "inputs": {
      "host": {
        "connectionName": "webde-imap",
        "operationId": "OnNewEmail"
      },
      "parameters": {
        "folderPath": "INBOX",
        "subjectFilter": "order,bestell,anfrage,purchase",
        "importance": "Any",
        "includeAttachments": true
      }
    },
    "recurrence": {
      "frequency": "Minute",
      "interval": 5
    }
  }
}
```

#### B. AI Foundry Agent Integration
```json
{
  "actions": {
    "Process_Order_with_AI_Agent": {
      "type": "ApiConnection",
      "inputs": {
        "host": {
          "connectionName": "ai-foundry-connection",
          "operationId": "TriggerAgent"
        },
        "parameters": {
          "agentId": "order-processing-agent",
          "threadId": "@{guid()}",
          "message": {
            "role": "user",
            "content": "Process this order email:\n\nSubject: @{triggerOutputs()?['body/subject']}\nFrom: @{triggerOutputs()?['body/from']}\nBody: @{triggerOutputs()?['body/bodyPlainText']}"
          },
          "instructions": "Analyze this order email and generate a professional response draft. Extract all order details and create a confirmation response."
        }
      }
    }
  }
}
```

#### C. Draft Storage Logic
```json
{
  "actions": {
    "Store_Draft_in_Postbox": {
      "type": "ApiConnection",
      "inputs": {
        "host": {
          "connectionName": "azureblob",
          "operationId": "CreateBlob"
        },
        "parameters": {
          "containerName": "email-drafts",
          "blobName": "draft-@{utcNow('yyyyMMdd-HHmmss')}-@{guid()}.json",
          "blobContent": {
            "originalEmail": {
              "subject": "@{triggerOutputs()?['body/subject']}",
              "from": "@{triggerOutputs()?['body/from']}",
              "body": "@{triggerOutputs()?['body/bodyPlainText']}",
              "receivedTime": "@{triggerOutputs()?['body/dateTimeReceived']}"
            },
            "aiAnalysis": "@{outputs('Process_Order_with_AI_Agent')['body']}",
            "draftResponse": "@{outputs('Process_Order_with_AI_Agent')['body']['response']}",
            "status": "pending_approval",
            "createdTime": "@{utcNow()}"
          }
        }
      }
    }
  }
}
```

#### D. Approval Notification
```json
{
  "actions": {
    "Send_Approval_Notification": {
      "type": "ApiConnection",
      "inputs": {
        "host": {
          "connectionName": "teams",
          "operationId": "PostAdaptiveCard"
        },
        "parameters": {
          "recipient": "order-approval-team",
          "card": {
            "type": "AdaptiveCard",
            "body": [
              {
                "type": "TextBlock",
                "text": "New Order Response Draft Ready for Approval",
                "weight": "Bolder",
                "size": "Medium"
              },
              {
                "type": "TextBlock",
                "text": "Original Email: @{triggerOutputs()?['body/subject']}"
              },
              {
                "type": "TextBlock",
                "text": "Customer: @{triggerOutputs()?['body/from']}"
              }
            ],
            "actions": [
              {
                "type": "Action.Submit",
                "title": "Approve & Send",
                "data": {"action": "approve", "draftId": "@{outputs('Store_Draft_in_Postbox')['body']['blobName']}"}
              },
              {
                "type": "Action.Submit", 
                "title": "Request Changes",
                "data": {"action": "reject", "draftId": "@{outputs('Store_Draft_in_Postbox')['body']['blobName']}"}
              }
            ]
          }
        }
      }
    }
  }
}
```

### 3. Azure CLI Deployment Scripts (Using Existing .env Configuration)

#### load-env-config.sh
```bash
#!/bin/bash

# Load existing Azure configuration from .env file
if [ -f ".env" ]; then
    echo "Loading Azure configuration from .env..."
    export $(cat .env | xargs)
    echo "✅ Configuration loaded successfully"
    echo "Using Subscription: $AZURE_SUBSCRIPTION_ID"
    echo "Resource Group: $AZURE_RESOURCE_GROUP"
    echo "AI Foundry Project: $AI_FOUNDRY_PROJECT_NAME"
else
    echo "❌ Error: .env file not found"
    exit 1
fi

# Verify required variables
required_vars=("AZURE_SUBSCRIPTION_ID" "AZURE_RESOURCE_GROUP" "AI_FOUNDRY_PROJECT_NAME" "EMAIL_USERNAME")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: Required variable $var not set in .env"
        exit 1
    fi
done

echo "✅ All required configuration variables verified"
```

#### setup-agent.sh (Uses Existing AI Foundry Project)
```bash
#!/bin/bash

# Load configuration
source ./scripts/load-env-config.sh

# Set Azure subscription
az account set --subscription $AZURE_SUBSCRIPTION_ID

echo "Creating order processing agent in existing AI Foundry project..."

# Create AI agent in existing project
az ai-foundry agent create \
  --name "order-processing-agent" \
  --description "Processes order emails and generates response drafts" \
  --instructions-file "./ai-foundry/agent-instructions.txt" \
  --model "gpt-4" \
  --project $AI_FOUNDRY_PROJECT_NAME \
  --resource-group $AZURE_RESOURCE_GROUP

# Upload knowledge base to existing project
echo "Uploading knowledge base..."
az ai-foundry knowledge upload \
  --agent-name "order-processing-agent" \
  --files "./ai-foundry/knowledge-base/" \
  --project $AI_FOUNDRY_PROJECT_NAME

echo "✅ AI Foundry agent setup complete using existing project!"
```

#### deploy-workflow.sh (Uses Existing Logic Apps Resource)
```bash
#!/bin/bash

# Load configuration  
source ./scripts/load-env-config.sh

echo "Deploying Logic Apps workflow to existing resource..."

# Create workflow definition with environment variables
envsubst < ./logic-app/order-processing-workflow.template.json > ./logic-app/order-processing-workflow.json

# Deploy to existing Logic Apps resource (if exists) or create new one
if az logic workflow show --resource-group $AZURE_RESOURCE_GROUP --name "email-order-processor" &>/dev/null; then
    echo "Updating existing Logic Apps workflow..."
    az logic workflow update \
      --resource-group $AZURE_RESOURCE_GROUP \
      --name "email-order-processor" \
      --definition "@./logic-app/order-processing-workflow.json"
else
    echo "Creating new Logic Apps workflow..."
    az logic workflow create \
      --resource-group $AZURE_RESOURCE_GROUP \
      --name "email-order-processor" \
      --definition "@./logic-app/order-processing-workflow.json" \
      --location $AZURE_LOCATION
fi

echo "✅ Logic Apps workflow deployed successfully!"
```

#### configure-connections.sh (Uses Existing Resources)
```bash
#!/bin/bash

# Load configuration
source ./scripts/load-env-config.sh

echo "Configuring API connections with existing Azure resources..."

# Create IMAP connection using existing credentials
az logic api-connection create \
  --resource-group $AZURE_RESOURCE_GROUP \
  --name "webde-imap-connection" \
  --api-id "/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$AZURE_LOCATION/managedApis/imap" \
  --parameters '{
    "server": "'$IMAP_SERVER'",
    "port": 993,
    "username": "'$EMAIL_USERNAME'",
    "password": "'$EMAIL_PASSWORD'",
    "sslEnabled": true
  }'

# Create AI Foundry connection using existing project
az logic api-connection create \
  --resource-group $AZURE_RESOURCE_GROUP \
  --name "ai-foundry-connection" \
  --api-id "/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$AZURE_LOCATION/managedApis/ai-foundry" \
  --parameters '{
    "projectEndpoint": "'$AI_FOUNDRY_ENDPOINT'",
    "agentId": "order-processing-agent"
  }'

# Create storage connection using existing storage account
az logic api-connection create \
  --resource-group $AZURE_RESOURCE_GROUP \
  --name "storage-connection" \
  --api-id "/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$AZURE_LOCATION/managedApis/azureblob" \
  --parameters '{
    "connectionString": "'$AZURE_STORAGE_CONNECTION_STRING'"
  }'

echo "✅ API connections configured with existing resources!"
```

### 2. Deployment Infrastructure (`deployment/`)

#### PowerShell Scripts:
**deploy-logic-app.ps1**
- Deploy Logic Apps Standard resource
- Configure all necessary connections
- Set up proper RBAC permissions
- Deploy workflow definition

**setup-connections.ps1**
- Create IMAP API connection for matthias.buchhorn@web.de
- Configure web.de server settings (imap.web.de:993)
- Configure Azure OpenAI/Cognitive Services connections
- Set up Storage Account connections
- Configure SMTP connector for outbound notifications

#### Terraform Configuration (`terraform/`):
**main.tf** - Create these resources ONLY:
- Logic Apps Standard workspace
- Storage Account for data and logs
- Azure OpenAI or Cognitive Services resource
- Application Insights for monitoring
- Key Vault for secrets (connection strings only)

**variables.tf**:
- Environment-specific parameters
- Email account configuration
- AI service settings
- Storage configuration

**outputs.tf**:
- Logic Apps endpoint URLs
- Storage account information
- Monitoring dashboard links

### 3. Configuration Management (`config/`)

#### ai-configuration.json:
```json
{
  "classification": {
    "categories": ["urgent", "sales", "support", "personal", "newsletter", "spam"],
    "prompts": {
      "classify": "Classify this email into one of these categories based on content and sender...",
      "sentiment": "Analyze the sentiment and urgency level of this email...",
      "intent": "Determine what action is needed for this email..."
    }
  },
  "responses": {
    "urgent": "immediate notification",
    "sales": "route to sales team",
    "support": "create support ticket",
    "personal": "flag for review",
    "newsletter": "archive",
    "spam": "delete"
  }
}
```

#### environment-settings.json:
```json
{
  "email": {
    "account": "matthias.buchhorn@web.de",
    "folders": ["Inbox"],
    "processing_rules": {
      "max_email_size": "10MB",
      "include_attachments": true,
      "archive_processed": true
    }
  },
  "ai_services": {
    "openai_model": "gpt-4",
    "text_analytics_features": ["sentiment", "key_phrases", "entities"],
    "confidence_threshold": 0.8
  },
  "storage": {
    "retention_days": 90,
    "archive_old_emails": true,
    "log_all_actions": true
  }
}
```

#### email-rules.json:
```json
{
  "urgent_keywords": ["urgent", "asap", "emergency", "critical"],
  "spam_indicators": ["free money", "click here", "limited time"],
  "sender_whitelist": ["trusted-domain.com"],
  "auto_responses": {
    "out_of_office": true,
    "acknowledgment": true,
    "escalation_threshold": "high_priority"
  }
}
```

### 4. Testing Strategy (`tests/`)

#### Test Email Scenarios (`test-emails/`):
Create sample emails for testing:
- **urgent-email.txt**: High-priority business email
- **sales-inquiry.txt**: Sales lead email
- **support-request.txt**: Technical support request
- **personal-email.txt**: Personal communication
- **newsletter.txt**: Marketing newsletter
- **spam-email.txt**: Spam/junk email

#### Workflow Tests (`workflow-tests.json`):
```json
{
  "test_scenarios": [
    {
      "name": "urgent_email_processing",
      "input": "urgent-email.txt",
      "expected_output": {
        "category": "urgent",
        "sentiment": "neutral",
        "action": "immediate_notification"
      }
    },
    {
      "name": "spam_detection",
      "input": "spam-email.txt",
      "expected_output": {
        "category": "spam",
        "action": "delete"
      }
    }
  ]
}
```

## TECHNICAL SPECIFICATIONS

### Logic Apps Requirements:
- **Tier**: Standard (for advanced features and better performance)
- **Plan**: WS1 or higher for reliable processing
- **Connectors**: Only built-in and certified connectors
- **Authentication**: Managed Identity for Azure services
- **Monitoring**: Application Insights integration

### Native Connectors to Use:
1. **IMAP**: Email trigger and reading for web.de accounts
2. **SMTP**: Outbound email responses and notifications
3. **Azure OpenAI**: AI text processing and classification
4. **Text Analytics**: Sentiment analysis and key phrase extraction
5. **Azure Storage**: Data persistence and logging
6. **HTTP**: Generic REST API calls if needed

### Data Flow Design:
```
Email Received → Content Extraction → AI Analysis → Classification → Action Decision → Execute Actions → Log Results
```

### Security Requirements:
- **Managed Identity**: Use for all Azure service connections
- **Key Vault**: Store sensitive configuration only
- **RBAC**: Minimal required permissions
- **Encryption**: Enable at rest and in transit
- **Compliance**: GDPR considerations for email data

## IMPLEMENTATION CHECKLIST

### Phase 1: Validate Existing Azure Setup
- [ ] Verify .env file contains all required Azure configuration
- [ ] Test Azure CLI login with existing subscription
- [ ] Validate AI Foundry project access and permissions
- [ ] Verify storage account and connection string access
- [ ] Test email credentials (matthias.buchhorn@web.de)

### Phase 2: Deploy AI Foundry Agent (Using Existing Project)
- [ ] Load configuration from .env file
- [ ] Create order processing agent in existing AI Foundry project
- [ ] Upload knowledge base files to existing project
- [ ] Test agent with sample order emails
- [ ] Configure agent tools and model parameters

### Phase 3: Configure Logic Apps Integration
- [ ] Create or update Logic Apps workflow using existing resources
- [ ] Configure IMAP connection with web.de credentials from .env
- [ ] Set up AI Foundry connector using existing project endpoint
- [ ] Configure storage connections using existing storage account
- [ ] Test email trigger and agent integration

### Phase 4: Implement Order Processing Workflow
- [ ] Deploy complete order processing workflow
- [ ] Configure email filtering for order-related content
- [ ] Implement draft generation and storage using existing storage
- [ ] Set up approval workflow with Teams integration
- [ ] Configure SMTP connector for final email delivery

### Phase 5: Testing with Existing Infrastructure
- [ ] Test with sample German order emails
- [ ] Validate AI agent analysis using existing AI Foundry project
- [ ] Test approval workflow and notifications
- [ ] Verify final email delivery via SMTP
- [ ] Monitor using existing Application Insights (if configured)

## ENVIRONMENT CONFIGURATION

### Required .env Variables:
```bash
# The user's existing .env should contain:

# Azure Core (Required)
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_RESOURCE_GROUP=your-resource-group  
AZURE_LOCATION=your-location (e.g., "East US")

# AI Foundry (Required)
AI_FOUNDRY_PROJECT_NAME=your-existing-foundry-project
AI_FOUNDRY_ENDPOINT=your-foundry-endpoint
AZURE_OPENAI_ENDPOINT=your-openai-endpoint
AZURE_OPENAI_API_KEY=your-openai-key

# Email Configuration (Required)
EMAIL_USERNAME=matthias.buchhorn@web.de
EMAIL_PASSWORD=your-web.de-app-password
IMAP_SERVER=imap.web.de
SMTP_SERVER=smtp.web.de

# Storage (Required) 
AZURE_STORAGE_ACCOUNT=your-storage-account-name
AZURE_STORAGE_CONNECTION_STRING=your-storage-connection-string

# Optional (if available)
AZURE_APPLICATION_INSIGHTS=your-app-insights-name
TEAMS_WEBHOOK_URL=your-teams-webhook
```

### Configuration Validation:
```bash
# Run this to validate your .env configuration
./scripts/load-env-config.sh

# Expected output:
# ✅ Configuration loaded successfully
# Using Subscription: xxxxx-xxxxx-xxxxx
# Resource Group: your-rg
# AI Foundry Project: your-project
# ✅ All required configuration variables verified
```

## DELIVERABLES EXPECTED

1. **Complete AI Foundry Agent** with order processing capabilities
2. **Logic Apps workflow** handling end-to-end order processing
3. **Azure CLI deployment scripts** for automated setup
4. **Configuration files** for different environments
5. **Test scenarios** with sample order emails in German/English
6. **Documentation** covering setup, configuration, and operations
7. **Monitoring setup** with dashboards and alerts
8. **Approval workflow** with Teams integration

## SPECIFIC ORDER PROCESSING FEATURES

### Email Content Analysis:
- Extract product details, quantities, and specifications
- Identify customer information and contact details
- Detect delivery requirements and timelines
- Flag special requests or custom requirements

### Response Draft Generation:
- Professional greeting and order acknowledgment
- Detailed order summary and confirmation
- Estimated delivery timeframes
- Next steps and contact information
- Appropriate language (German/English) matching original

### Approval Process:
- Teams notification with order summary
- Draft preview with editing capabilities
- Approve/reject buttons with comments
- Automatic email sending after approval
- Audit trail of all approval decisions

Execute this implementation focusing on the complete order processing pipeline from email receipt to final customer response delivery.

## CONSTRAINTS AND LIMITATIONS

### What NOT to Include:
- **NO Azure Functions**: Use only Logic Apps native actions
- **NO Custom Code**: Rely on built-in connectors and expressions
- **NO Gmail Integration**: Focus only on Office 365/Outlook
- **NO Complex Multi-Agent Architecture**: Keep it simple and direct
- **NO External APIs**: Use only Azure native services

### Approved Technologies:
- Azure Logic Apps Standard
- IMAP connector for web.de email access
- SMTP connector for outbound email
- Azure OpenAI connector
- Azure Cognitive Services connectors
- Azure Storage connectors
- Built-in Logic Apps actions and expressions

## DELIVERABLES EXPECTED

1. **Complete Logic Apps workflow definition** that works end-to-end
2. **Automated deployment scripts** using PowerShell and Terraform
3. **Configuration files** for different environments and rules
4. **Test scenarios and validation** with sample emails
5. **Documentation** covering setup, configuration, and usage
6. **Monitoring setup** with dashboards and alerts

## IMPLEMENTATION NOTES

### Logic Apps Best Practices:
- Use expressions for data transformation instead of custom code
- Implement proper error handling with try-catch scopes
- Use parallel branches for independent operations
- Configure appropriate timeout and retry policies
- Use variables and compose actions for readability

### AI Service Integration:
- Use built-in connectors rather than HTTP actions where possible
- Implement proper prompt engineering within connector configurations
- Handle AI service rate limits and quotas
- Cache frequently used results when appropriate

### Monitoring and Debugging:
- Enable detailed logging in Logic Apps
- Use correlation IDs for tracking email processing
- Set up alerts for failures and performance issues
- Create dashboards for operational visibility

Execute this implementation focusing on simplicity, reliability, and maintainability using only Logic Apps native capabilities.