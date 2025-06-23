# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Jasmin Catering AI Agent is an automated catering inquiry processing system for a Syrian fusion restaurant in Berlin. The system uses Azure LogicApps to monitor Gmail and forward catering inquiries to Slack, with plans to integrate AI-powered offer generation.

## Architecture

**Current Implementation:**
- Azure LogicApps monitors `mabu.mate@gmail.com` inbox
- Forwards emails to Slack channel `#gmail-inbox` in `mabured.slack.com`
- Manual OAuth authorization required for Gmail and Slack connections

**Azure Resources:**
- Subscription: `b58b1820-35f0-4271-99be-7c84d4dd40f3`
- Resource Group: `logicapp-jasmin-catering_group`
- LogicApp: `mabu-logicapps`
- Location: West Europe

## Essential Commands

### Deployment
```bash
# Deploy LogicApp (main deployment script)
./scripts/deploy-logicapp.sh

# Alternative deployment with Azure Developer CLI
azd up

# Backup to GitHub after changes
./scripts/backup-to-github.sh
```

### Monitoring and Testing
```bash
# Check LogicApp status
az logicapp show --resource-group logicapp-jasmin-catering_group --name mabu-logicapps

# List recent runs
az logicapp run list --resource-group logicapp-jasmin-catering_group --name mabu-logicapps

# Check connection status
az resource show --resource-group logicapp-jasmin-catering_group --name gmail-mabu-mate
az resource show --resource-group logicapp-jasmin-catering_group --name slack-mabured
```

## Deployment Workflow

1. Run `./scripts/deploy-logicapp.sh`
2. Go to Azure Portal and authorize OAuth connections:
   - Gmail connection: `gmail-mabu-mate`
   - Slack connection: `slack-mabured`
3. Test by sending email to `mabu.mate@gmail.com`
4. Verify message appears in Slack `#gmail-inbox`
5. Run `./scripts/backup-to-github.sh` to save changes

## Key Files

- `logicapp/workflow-definition.json` - Main LogicApp workflow
- `logicapp/current-workflow.json` - Active deployed workflow
- `config/azure-resources.json` - Azure resource configuration
- `scripts/deploy-logicapp.sh` - Main deployment script
- `scripts/backup-to-github.sh` - GitHub backup script

## Important Notes

- OAuth tokens require manual authorization in Azure Portal after deployment
- The deployment script uses `jq` for JSON manipulation
- All customer communication will be in German
- System handles catering for 15-500 guests
- Future phases will add AI agent for automated offer generation