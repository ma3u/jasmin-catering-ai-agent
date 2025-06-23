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
 * HTTP-triggered function for Gmail push notifications
 * Gmail can send real-time notifications when new emails arrive
 */
app.http('gmailWebhook', {
  methods: ['POST'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    context.log('Gmail webhook triggered');

    try {
      // Parse the push notification from Gmail
      const body = await request.json();
      
      // Gmail sends a base64-encoded message
      if (!body.message || !body.message.data) {
        return {
          status: 400,
          body: 'Invalid webhook payload'
        };
      }

      // Decode the notification
      const messageData = JSON.parse(
        Buffer.from(body.message.data, 'base64').toString('utf-8')
      );

      context.log('Webhook data:', messageData);

      // Get Gmail client
      const gmail = await gmailAuth.getGmailClient();

      // Get the email that triggered the notification
      const historyId = messageData.historyId;
      
      // Get history changes since last known history ID
      const historyResponse = await gmail.users.history.list({
        userId: 'me',
        startHistoryId: await stateManager.getLastHistoryId() || historyId - 1,
        historyTypes: ['messageAdded']
      });

      if (!historyResponse.data.history) {
        context.log('No new messages in history');
        return { status: 200, body: 'No new messages' };
      }

      // Process new messages
      for (const historyRecord of historyResponse.data.history) {
        if (historyRecord.messagesAdded) {
          for (const addedMessage of historyRecord.messagesAdded) {
            const messageId = addedMessage.message.id;
            
            // Get full message details
            const message = await gmail.users.messages.get({
              userId: 'me',
              id: messageId
            });

            // Parse the email
            const parsedEmail = EmailParser.parseMessage(message.data);
            context.log(`Processing email: ${parsedEmail.subject} from ${parsedEmail.from}`);

            // Check if it's a catering inquiry
            if (EmailParser.isCateringInquiry(parsedEmail)) {
              // Extract additional information
              parsedEmail.guestCount = EmailParser.extractGuestCount(parsedEmail.body);
              parsedEmail.eventDate = EmailParser.extractEventDate(parsedEmail.body);

              // Send to Slack immediately
              await slackNotifier.sendCateringInquiry(parsedEmail);
              context.log('Catering inquiry sent to Slack');
            }
          }
        }
      }

      // Update last history ID
      await stateManager.updateLastHistoryId(historyId);

      return {
        status: 200,
        body: 'Webhook processed successfully'
      };

    } catch (error) {
      context.error('Gmail webhook error:', error);
      return {
        status: 500,
        body: 'Internal server error'
      };
    }
  }
});