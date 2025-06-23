const { app } = require('@azure/functions');
const GmailAuth = require('../auth/gmailAuth');
const EmailParser = require('../utils/emailParser');
const SlackNotifier = require('../utils/slackNotifier');
const StateManager = require('../utils/stateManager');

// Initialize services
const gmailAuth = new GmailAuth();
const slackNotifier = new SlackNotifier();
const stateManager = new StateManager();

/**
 * Timer-triggered function to check Gmail for new emails
 * Runs every 5 minutes
 */
app.timer('gmailMonitor', {
  schedule: '0 */5 * * * *', // Every 5 minutes
  handler: async (myTimer, context) => {
    context.log('Gmail Monitor function started');

    try {
      // Get Gmail client
      const gmail = await gmailAuth.getGmailClient();
      
      // Get last checked time from storage (or default to 1 hour ago)
      const lastChecked = await stateManager.getLastCheckedTime();
      const query = `is:unread after:${lastChecked} to:${process.env.GMAIL_USER_EMAIL}`;

      // List messages
      const response = await gmail.users.messages.list({
        userId: 'me',
        q: query,
        maxResults: 10
      });

      if (!response.data.messages || response.data.messages.length === 0) {
        context.log('No new messages found');
        return;
      }

      context.log(`Found ${response.data.messages.length} new messages`);

      // Process each message
      for (const messageInfo of response.data.messages) {
        try {
          // Get full message details
          const message = await gmail.users.messages.get({
            userId: 'me',
            id: messageInfo.id
          });

          // Parse the email
          const parsedEmail = EmailParser.parseMessage(message.data);
          context.log(`Processing email: ${parsedEmail.subject} from ${parsedEmail.from}`);

          // Check if it's a catering inquiry
          if (EmailParser.isCateringInquiry(parsedEmail)) {
            // Extract additional information
            parsedEmail.guestCount = EmailParser.extractGuestCount(parsedEmail.body);
            parsedEmail.eventDate = EmailParser.extractEventDate(parsedEmail.body);

            // Send to Slack
            await slackNotifier.sendCateringInquiry(parsedEmail);
            context.log('Catering inquiry sent to Slack');
          }

          // Mark as read
          await gmail.users.messages.modify({
            userId: 'me',
            id: messageInfo.id,
            requestBody: {
              removeLabelIds: ['UNREAD']
            }
          });

        } catch (emailError) {
          context.error(`Error processing message ${messageInfo.id}:`, emailError);
        }
      }

      // Update last checked time
      await stateManager.updateLastCheckedTime(Math.floor(Date.now() / 1000));

    } catch (error) {
      context.error('Gmail Monitor function error:', error);
      
      // If it's an auth error, we might need to refresh the token
      if (error.code === 401) {
        try {
          await gmailAuth.refreshAccessToken();
          context.log('Access token refreshed successfully');
        } catch (refreshError) {
          context.error('Failed to refresh access token:', refreshError);
        }
      }
    }
  }
});