const { google } = require('googleapis');

class GmailAuth {
  constructor() {
    this.oauth2Client = new google.auth.OAuth2(
      process.env.GMAIL_CLIENT_ID,
      process.env.GMAIL_CLIENT_SECRET,
      'https://developers.google.com/oauthplayground' // Redirect URI for manual auth
    );
    
    // Alternative OAuth client for Logic Apps redirect URIs
    this.oauth2ClientAlt = new google.auth.OAuth2(
      process.env.GMAIL_CLIENT_ID,
      process.env.GMAIL_CLIENT_SECRET,
      'https://logic-apis-westeurope.consent.azure-apim.net/redirect/gmail'
    );

    // Set credentials if we have a refresh token
    if (process.env.GMAIL_REFRESH_TOKEN) {
      this.oauth2Client.setCredentials({
        refresh_token: process.env.GMAIL_REFRESH_TOKEN
      });
    }
  }

  /**
   * Get authorization URL for initial setup
   */
  getAuthUrl() {
    const scopes = [
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/gmail.modify'
    ];

    return this.oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: scopes,
      prompt: 'consent'
    });
  }

  /**
   * Exchange authorization code for tokens
   */
  async getTokenFromCode(code) {
    const { tokens } = await this.oauth2Client.getToken(code);
    this.oauth2Client.setCredentials(tokens);
    return tokens;
  }

  /**
   * Get authenticated Gmail client
   */
  async getGmailClient() {
    // Ensure we have valid credentials
    const credentials = await this.oauth2Client.getAccessToken();
    if (!credentials.token) {
      throw new Error('No valid access token available. Please authenticate first.');
    }

    return google.gmail({ version: 'v1', auth: this.oauth2Client });
  }

  /**
   * Refresh access token if needed
   */
  async refreshAccessToken() {
    try {
      const { credentials } = await this.oauth2Client.refreshAccessToken();
      this.oauth2Client.setCredentials(credentials);
      return credentials;
    } catch (error) {
      console.error('Error refreshing access token:', error);
      throw error;
    }
  }
}

module.exports = GmailAuth;