# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Azure-based automated catering inquiry processing system for Jasmin Catering, a Syrian fusion restaurant in Berlin. The system monitors emails, detects catering inquiries, and facilitates team approval through Slack integration, with plans for AI-powered automated responses.

## Essential Commands

### Deployment
```bash
# Deploy using Azure Developer CLI
azd up

# Manual Azure login if needed
az login
az account set --subscription b58b1820-35f0-4271-99be-7c84d4dd40f3
```

### Testing
```bash
# Test the workflow by sending an email to:
# matthias.buchhorn@web.de


# Check Logic App status
az logicapp show --resource-group logicapp-jasmin-catering_group --name mabu-logicapps

# View recent runs
az logicapp run list --resource-group logicapp-jasmin-catering_group --name mabu-logicapps
```

## Architecture

### Current Implementation (Phase 1)
1. **Email Monitoring**: Logic App monitors web.de inbox via IMAP
2. **Inquiry Detection**: Filters German catering inquiries using keywords
3. **Slack Notification**: Sends formatted messages to #email-approvals channel
4. **Human Approval**: Team approves/rejects via Slack interactive buttons
5. **Automated Response**: Sends pre-defined German responses via SMTP

### Key Components
- **Azure Logic Apps (Consumption)**: Workflow orchestration (JSON-based definitions)
- **Azure AI Foundry**: Future AI agent integration (Phases 2-4)
- **Slack Integration**: Team notifications and approval workflow
- **Email Services**: web.de for monitoring, SMTP for responses

### Environment Configuration
All configuration is in `.env` file:
- Azure subscription and resource details
- Email credentials for web.de
- Slack bot token and channel settings
- AI Foundry project configuration

### Business Context
- **Service**: Syrian fusion catering in Berlin
- **Languages**: German (primary), English
- **Event sizes**: 15-500 guests
- **Key offerings**: Humus with Love, Malakieh desserts, vegan options
- **Response templates**: Located in environment variables (APPROVAL_EMAIL_*, REJECTION_EMAIL_*)

## Development Notes

1. **No local build required** - Logic Apps are JSON-based and deployed directly to Azure
2. **Testing requires real email** - Send test emails to configured addresses
3. **OAuth connections** must be authorized manually in Azure Portal after deployment
4. **Slack bot** must be configured in workspace before deployment

## Important Considerations

- The project recently underwent major refactoring (many files deleted)
- Focus is on cloud-based services rather than local development
- AI integration is planned but not yet implemented
- All workflow logic resides in Azure Logic Apps, not in code files