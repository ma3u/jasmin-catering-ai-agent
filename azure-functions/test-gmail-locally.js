// Test Gmail credentials locally
require('dotenv').config();
const { google } = require('googleapis');

async function testGmailConnection() {
  console.log('🔍 Testing Gmail Connection...\n');
  
  // Check environment variables
  console.log('📋 Environment Check:');
  console.log(`Client ID: ${process.env.GMAIL_CLIENT_ID ? '✅ Set' : '❌ Missing'}`);
  console.log(`Client Secret: ${process.env.GMAIL_CLIENT_SECRET ? '✅ Set' : '❌ Missing'}`);
  console.log(`Refresh Token: ${process.env.GMAIL_REFRESH_TOKEN ? '✅ Set' : '❌ Missing'}`);
  console.log(`User Email: ${process.env.GMAIL_USER_EMAIL || 'Not set'}\n`);

  if (!process.env.GMAIL_REFRESH_TOKEN) {
    console.log('⚠️  Please add your refresh token to the .env file first!');
    console.log('Run: ./oauth-playground-direct-link.sh for instructions\n');
    return;
  }

  try {
    // Create OAuth2 client
    const oauth2Client = new google.auth.OAuth2(
      process.env.GMAIL_CLIENT_ID,
      process.env.GMAIL_CLIENT_SECRET,
      'https://developers.google.com/oauthplayground'
    );

    // Set credentials
    oauth2Client.setCredentials({
      refresh_token: process.env.GMAIL_REFRESH_TOKEN
    });

    // Create Gmail client
    const gmail = google.gmail({ version: 'v1', auth: oauth2Client });

    // Test: Get user profile
    console.log('📧 Getting Gmail profile...');
    const profile = await gmail.users.getProfile({ userId: 'me' });
    console.log(`✅ Connected to: ${profile.data.emailAddress}`);
    console.log(`   Total messages: ${profile.data.messagesTotal}`);
    console.log(`   Total threads: ${profile.data.threadsTotal}\n`);

    // Test: List recent messages
    console.log('📬 Checking recent messages...');
    const messages = await gmail.users.messages.list({
      userId: 'me',
      maxResults: 5,
      q: 'is:unread'
    });

    if (messages.data.messages && messages.data.messages.length > 0) {
      console.log(`Found ${messages.data.messages.length} unread messages\n`);
    } else {
      console.log('No unread messages found\n');
    }

    console.log('✅ Gmail connection test successful!');
    console.log('You can now deploy with: ./deploy-with-env.sh');

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.message.includes('invalid_grant')) {
      console.log('\n⚠️  Your refresh token may be expired or invalid.');
      console.log('Please get a new one from OAuth Playground.');
    }
  }
}

testGmailConnection();