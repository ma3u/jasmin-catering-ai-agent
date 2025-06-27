# Archive Directory

This directory contains experimental and deprecated scripts that were part of the development process but are not part of the current working solution.

## Why These Files Were Archived

The Jasmin Catering AI Agent project evolved through several iterations:

1. **Initial approach**: Azure AI Agents and Assistants API
2. **Second approach**: RAG-enhanced vector search  
3. **Final approach**: Direct GPT-4 integration via Azure Cognitive Services

The final working solution uses Azure Logic Apps with direct GPT-4 API calls, making these experimental approaches unnecessary.

## Archived Contents

### `/scripts/` - Experimental Python and Shell Scripts

**Assistant/Agent Scripts** (Python):
- `configure-*.py` - Various attempts at configuring Azure AI Assistants
- `create-*-agent*.py` - Scripts for creating Azure AI Agents
- `upload-*.py` - Document upload utilities for agents

**Experimental Deployment Scripts** (Shell):
- `deploy-rag-enhanced.sh` - RAG (Retrieval Augmented Generation) deployment
- `setup-vector-db.sh` - Vector database setup for semantic search
- `update-to-assistant.sh` - Migration to Assistant API
- `update-to-new-agent.sh` - Agent update utilities
- `deploy-with-prompt.sh` - Prompt-based deployment approach
- `deploy-chat-completions.sh` - Chat completions deployment

### `/logic-apps/` - Experimental Workflow Definitions

- `agent-config.json` - Agent configuration attempts
- `email-processor-assistant-workflow.json` - Assistant API workflow
- `email-processor-workflow-foundry.json` - AI Foundry specific workflow
- `email-processor-workflow-rag.json` - RAG-enhanced workflow
- `logic-app-template.json` - ARM template experiments
- `*.parameters.json` - Various parameter files

## Current Working Solution

The active deployment uses:
- **Scripts**: `deploy-main.sh`, `deploy-ai-foundry.sh`, `monitor-logic-app.sh`, `load-env-config.sh`
- **Workflows**: `email-processor-workflow.json`, `ai-foundry-workflow.json`
- **Approach**: Direct Azure Cognitive Services GPT-4 API integration

## Note

These files are kept for reference and potential future use but should not be used for current deployments. Always use the scripts in the parent directories for production deployments.