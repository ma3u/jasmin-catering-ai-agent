# Security Guidelines

## 🚨 CRITICAL: Never Commit Sensitive Information

### Protected Information
The following should NEVER be committed to version control:
- App-specific passwords
- API keys
- Connection strings
- OAuth tokens
- Personal email addresses (in production)
- Azure subscription IDs (in public repos)

### Configuration Files
- ✅ **DO**: Use `.env` files for sensitive configuration
- ✅ **DO**: Reference environment variables in code
- ❌ **DON'T**: Hardcode credentials in any file
- ❌ **DON'T**: Include actual passwords in documentation

### Documentation
When documenting configuration:
- Use placeholders: `[YOUR_PASSWORD_HERE]`
- Reference `.env`: "See .env file for actual value"
- Example formats without real data

### Before Committing
Always check:
```bash
# Search for potential secrets
grep -r "PASSWORD\|KEY\|TOKEN\|SECRET" . --exclude-dir=.git --exclude=.env

# Check git status
git status
git diff --staged
```

### If You Accidentally Commit Secrets
1. Immediately revoke/change the exposed credential
2. Remove from repository history:
```bash
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch PATH_TO_FILE' \
  --prune-empty --tag-name-filter cat -- --all
```
3. Force push to all branches
4. Notify team members

### Azure Best Practices
- Use Azure Key Vault for production secrets
- Enable Managed Identity where possible
- Rotate credentials regularly
- Use app-specific passwords for email accounts

## Environment File Template
Create `.env` from this template:
```bash
# Azure Configuration
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_RESOURCE_GROUP=your-resource-group

# Email Configuration
WEBDE_EMAIL_ALIAS=your-alias@email.de
WEBDE_APP_PASSWORD=[APP_SPECIFIC_PASSWORD]

# Never commit the actual .env file!
```