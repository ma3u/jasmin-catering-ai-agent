# Web.de Alias Configuration Guide

## Email Alias Setup

Your web.de email alias has been configured with the following settings:

### Email Configuration
- **Email Alias**: `ma3u-test@email.de`
- **App Password**: `[STORED IN .env FILE - DO NOT COMMIT]`
- **IMAP Server**: `imap.web.de` (Port 993, SSL)
- **SMTP Server**: `smtp.web.de` (Port 587, TLS)

### Logic Apps Email Filtering

The Logic Apps workflow has been configured to:
1. **Only monitor emails sent TO**: `ma3u-test@email.de`
2. **Subject keywords**: "order", "bestell", "anfrage", "catering", "event"
3. **Check frequency**: Every 5 minutes

### How It Works

```
Email sent to ma3u-test@email.de
           ↓
Logic App checks "To" field matches alias
           ↓
Subject contains catering keywords?
           ↓
Process with AI Agent
```

## Testing Your Configuration

### Step 1: Deploy with Updated Settings
```bash
cd ai-foundry-email-processor
./scripts/configure-connections.sh
```

### Step 2: Send Test Email
Send an email with these characteristics:
- **To**: `ma3u-test@email.de` (MUST match exactly)
- **Subject**: Must contain one of: "Catering", "Anfrage", "Order", "Bestell", "Event"
- **From**: Any email address

Example test email:
```
To: ma3u-test@email.de
Subject: Catering Anfrage für Geburtstagsfeier
Body: 
Hallo,
ich möchte ein Catering für 30 Personen buchen.
Datum: 15. Juli 2025
Mit freundlichen Grüßen
```

### Step 3: Verify Processing
```bash
# Check if email was received
az logic workflow run list \
  --resource-group logicapp-jasmin-catering_group \
  --workflow-name jasmin-order-processor \
  --top 5 \
  --output table
```

## Important Notes

1. **Email Filtering**: The system will ONLY process emails sent directly to `ma3u-test@email.de`. Emails where this address is in CC or BCC will be ignored.

2. **Authentication**: The app-specific password is now stored in `.env` and will be used automatically by the deployment scripts.

3. **Security**: Never commit the `.env` file to version control. The app password should remain confidential.

4. **Testing**: Always use the exact alias address when testing. The system performs exact matching on the "To" field.

## Troubleshooting

### Email Not Being Processed?

1. **Check exact "To" address**:
   - Must be exactly `ma3u-test@email.de`
   - No extra spaces or characters

2. **Verify subject keywords**:
   - At least one keyword must be present
   - Case-insensitive matching

3. **Check connection status**:
```bash
az resource show \
  --resource-group logicapp-jasmin-catering_group \
  --resource-type "Microsoft.Web/connections" \
  --name "webde-imap-connection" \
  --query "properties"
```

4. **Test IMAP connection manually**:
```bash
# Test with curl (requires base64 encoding of credentials)
openssl s_client -connect imap.web.de:993 -crlf
```

## Updating the Configuration

To change the email alias or password:

1. Update `.env` file:
```bash
WEBDE_EMAIL_ALIAS=new-alias@email.de
WEBDE_APP_PASSWORD=[YOUR_APP_PASSWORD_HERE]
```

2. Update Logic Apps workflow:
```bash
# Edit the workflow JSON
nano logic-app/order-processing-workflow.json
# Update the "toFilter" field with new alias
```

3. Re-deploy connections:
```bash
./scripts/configure-connections.sh
```