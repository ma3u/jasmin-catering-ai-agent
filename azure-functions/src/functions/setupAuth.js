const { app } = require('@azure/functions');
const GmailAuth = require('../auth/gmailAuth');

const gmailAuth = new GmailAuth();

/**
 * HTTP endpoint to get Gmail OAuth URL for initial setup
 */
app.http('getAuthUrl', {
  methods: ['GET'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    try {
      const useAlt = request.query.get('useAlt') === 'true';
      const authUrl = gmailAuth.getAuthUrl();
      const altAuthUrl = gmailAuth.oauth2ClientAlt.generateAuthUrl({
        access_type: 'offline',
        scope: [
          'https://www.googleapis.com/auth/gmail.readonly',
          'https://www.googleapis.com/auth/gmail.modify'
        ],
        prompt: 'consent'
      });
      
      return {
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          authUrl: authUrl,
          alternativeAuthUrl: altAuthUrl,
          instructions: [
            'IMPORTANT: You need to add the OAuth Playground redirect URI first!',
            '',
            'Option 1 (Recommended):',
            '1. Go to Google Cloud Console and add this redirect URI:',
            '   https://developers.google.com/oauthplayground',
            '2. Then visit the authUrl above',
            '',
            'Option 2 (Using existing Logic Apps URI):',
            '1. Visit the alternativeAuthUrl',
            '2. After authorization, you\'ll be redirected to Azure',
            '3. Copy the "code" parameter from the URL',
            '4. Call POST /api/exchangeToken with {"code": "YOUR_CODE"}'
          ],
          googleConsoleUrl: 'https://console.cloud.google.com/apis/credentials?project=jasmin-catering-logicapp'
        })
      };
    } catch (error) {
      context.error('Error generating auth URL:', error);
      return {
        status: 500,
        body: JSON.stringify({ error: error.message })
      };
    }
  }
});

/**
 * HTTP endpoint to exchange authorization code for tokens
 */
app.http('exchangeToken', {
  methods: ['POST'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    try {
      const body = await request.json();
      
      if (!body.code) {
        return {
          status: 400,
          body: JSON.stringify({ error: 'Authorization code is required' })
        };
      }

      const tokens = await gmailAuth.getTokenFromCode(body.code);
      
      return {
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          success: true,
          message: 'Tokens received successfully',
          refreshToken: tokens.refresh_token,
          instructions: [
            '1. Copy the refresh_token value',
            '2. Add it to your Azure Function App settings as GMAIL_REFRESH_TOKEN',
            '3. The Gmail integration is now ready to use'
          ]
        })
      };
    } catch (error) {
      context.error('Error exchanging token:', error);
      return {
        status: 500,
        body: JSON.stringify({ error: error.message })
      };
    }
  }
});

/**
 * HTTP endpoint to test Gmail connection
 */
app.http('testGmailConnection', {
  methods: ['GET'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    try {
      const gmail = await gmailAuth.getGmailClient();
      
      // Get user profile to test connection
      const profile = await gmail.users.getProfile({
        userId: 'me'
      });

      // List recent messages
      const messages = await gmail.users.messages.list({
        userId: 'me',
        maxResults: 5
      });

      return {
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          connected: true,
          profile: {
            emailAddress: profile.data.emailAddress,
            messagesTotal: profile.data.messagesTotal,
            threadsTotal: profile.data.threadsTotal
          },
          recentMessages: messages.data.messages || []
        })
      };
    } catch (error) {
      context.error('Gmail connection test failed:', error);
      return {
        status: 500,
        body: JSON.stringify({ 
          connected: false,
          error: error.message 
        })
      };
    }
  }
});