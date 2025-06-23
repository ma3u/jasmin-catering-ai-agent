const { WebClient } = require('@slack/web-api');

class SlackNotifier {
  constructor() {
    this.slack = new WebClient(process.env.SLACK_TOKEN);
    this.channel = process.env.SLACK_CHANNEL || 'gmail-inbox';
  }

  /**
   * Send catering inquiry notification to Slack
   */
  async sendCateringInquiry(parsedEmail) {
    const blocks = this.buildCateringInquiryBlocks(parsedEmail);
    
    try {
      const result = await this.slack.chat.postMessage({
        channel: this.channel,
        text: `New catering inquiry from ${parsedEmail.from}`,
        blocks: blocks
      });

      return result;
    } catch (error) {
      console.error('Error sending Slack message:', error);
      throw error;
    }
  }

  /**
   * Build Slack blocks for catering inquiry
   */
  buildCateringInquiryBlocks(email) {
    const blocks = [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: '📧 New Catering Inquiry for Jasmin Catering',
          emoji: true
        }
      },
      {
        type: 'section',
        fields: [
          {
            type: 'mrkdwn',
            text: `*From:*\n${email.from}`
          },
          {
            type: 'mrkdwn',
            text: `*Subject:*\n${email.subject}`
          }
        ]
      },
      {
        type: 'section',
        fields: [
          {
            type: 'mrkdwn',
            text: `*Received:*\n${new Date(email.date).toLocaleString()}`
          },
          {
            type: 'mrkdwn',
            text: `*Email ID:*\n${email.id}`
          }
        ]
      }
    ];

    // Add guest count and event date if extracted
    if (email.guestCount || email.eventDate) {
      const extractedFields = [];
      
      if (email.guestCount) {
        extractedFields.push({
          type: 'mrkdwn',
          text: `*Guest Count:*\n${email.guestCount} people`
        });
      }
      
      if (email.eventDate) {
        extractedFields.push({
          type: 'mrkdwn',
          text: `*Event Date:*\n${email.eventDate}`
        });
      }

      blocks.push({
        type: 'section',
        fields: extractedFields
      });
    }

    // Add email preview
    const preview = email.bodyText || email.snippet || '';
    const truncatedPreview = preview.length > 500 
      ? preview.substring(0, 497) + '...' 
      : preview;

    blocks.push({
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: `*Preview:*\n\`\`\`${truncatedPreview}\`\`\``
      }
    });

    // Add AI processing note
    blocks.push({
      type: 'context',
      elements: [
        {
          type: 'mrkdwn',
          text: '🤖 This email will be processed by the Jasmin Catering AI Agent for automated response generation'
        }
      ]
    });

    // Add actions
    blocks.push({
      type: 'actions',
      elements: [
        {
          type: 'button',
          text: {
            type: 'plain_text',
            text: '📧 View in Gmail',
            emoji: true
          },
          url: `https://mail.google.com/mail/u/0/#inbox/${email.id}`,
          style: 'primary'
        },
        {
          type: 'button',
          text: {
            type: 'plain_text',
            text: '🤖 Process with AI',
            emoji: true
          },
          value: email.id,
          action_id: 'process_with_ai'
        }
      ]
    });

    return blocks;
  }

  /**
   * Send simple notification message
   */
  async sendNotification(message) {
    try {
      const result = await this.slack.chat.postMessage({
        channel: this.channel,
        text: message
      });
      return result;
    } catch (error) {
      console.error('Error sending Slack notification:', error);
      throw error;
    }
  }

  /**
   * Send error notification
   */
  async sendError(error, context) {
    const blocks = [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: '⚠️ Gmail Integration Error',
          emoji: true
        }
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*Error:* ${error.message}`
        }
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*Context:* ${context}`
        }
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*Time:* ${new Date().toLocaleString()}`
        }
      }
    ];

    if (error.stack) {
      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*Stack Trace:*\n\`\`\`${error.stack.substring(0, 500)}...\`\`\``
        }
      });
    }

    try {
      await this.slack.chat.postMessage({
        channel: this.channel,
        text: 'Gmail Integration Error',
        blocks: blocks
      });
    } catch (slackError) {
      console.error('Failed to send error to Slack:', slackError);
    }
  }
}

module.exports = SlackNotifier;