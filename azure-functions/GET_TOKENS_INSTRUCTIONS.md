# 🔐 Get Your Missing Tokens

You need two tokens to complete the setup:

## 1. Gmail Refresh Token

### Step-by-Step Instructions:

1. **Open OAuth Playground**
   👉 https://developers.google.com/oauthplayground

2. **Configure OAuth Settings**
   - Click the gear icon ⚙️ in the top right
   - Check ✅ "Use your own OAuth credentials"
   - Enter:
     - **OAuth Client ID**: `YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com`
     - **OAuth Client secret**: `GOCSPX-YOUR_GOOGLE_CLIENT_SECRET`
   - Click "Close"

3. **Select Gmail Scopes**
   - In the left panel, find "Gmail API v1"
   - Select these two scopes:
     - ✅ `https://www.googleapis.com/auth/gmail.readonly`
     - ✅ `https://www.googleapis.com/auth/gmail.modify`

4. **Authorize**
   - Click "Authorize APIs"
   - Sign in with: `mabu.mate@gmail.com`
   - Click "Allow" to grant permissions

5. **Get Refresh Token**
   - Click "Exchange authorization code for tokens"
   - Copy the `refresh_token` value from the response
   - It will look something like: `1//0gxxxxxxxxxxxxxxxx`

6. **Add to .env file**
   ```bash
   # In azure-functions directory
   GMAIL_REFRESH_TOKEN=1//0gxxxxxxxxxxxxxxxx
   ```

---

## 2. Slack Bot Token

### Step-by-Step Instructions:

1. **Create Slack App**
   👉 https://api.slack.com/apps
   - Click "Create New App"
   - Choose "From scratch"
   - App Name: `Jasmin Catering Bot`
   - Workspace: `mabured.slack.com`

2. **Add Bot Permissions**
   - Go to "OAuth & Permissions" in sidebar
   - Scroll to "Scopes"
   - Add these Bot Token Scopes:
     - `chat:write`
     - `chat:write.public`
     - `channels:read`

3. **Install to Workspace**
   - Scroll up to "OAuth Tokens for Your Workspace"
   - Click "Install to Workspace"
   - Review and click "Allow"

4. **Copy Bot Token**
   - After installation, you'll see "Bot User OAuth Token"
   - Copy the token (starts with `xoxb-`)
   - Example: `xoxb-YOUR-SLACK-BOT-TOKEN-HERE`

5. **Add Bot to Channel**
   - In Slack, go to `#gmail-inbox` channel
   - Type: `/invite @Jasmin Catering Bot`

6. **Add to .env file**
   ```bash
   # In azure-functions directory
   SLACK_TOKEN=xoxb-YOUR-SLACK-BOT-TOKEN-HERE
   ```

---

## 3. Update Your .env File

Edit `/Users/ma3u/projects/jasmin-catering-ai-agent/azure-functions/.env`:

```env
# Gmail OAuth Credentials
GMAIL_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com
GMAIL_CLIENT_SECRET=GOCSPX-YOUR_GOOGLE_CLIENT_SECRET
GMAIL_REFRESH_TOKEN=YOUR_REFRESH_TOKEN_HERE
GMAIL_USER_EMAIL=mabu.mate@gmail.com

# Slack Configuration
SLACK_TOKEN=YOUR_SLACK_TOKEN_HERE
SLACK_CHANNEL=gmail-inbox
```

---

## 4. Deploy

After adding both tokens:

```bash
cd /Users/ma3u/projects/jasmin-catering-ai-agent/azure-functions
./deploy-with-env.sh
```

---

## Need Help?

- **Gmail Issues**: Make sure you're using the correct Google account (mabu.mate@gmail.com)
- **Slack Issues**: Make sure you're in the mabured.slack.com workspace
- **Token Format**:
  - Gmail refresh token: Usually starts with `1//`
  - Slack bot token: Always starts with `xoxb-`