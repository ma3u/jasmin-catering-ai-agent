// Load environment variables for local development
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

// Export all functions
module.exports = {
  ...require('./functions/gmailMonitor'),
  ...require('./functions/gmailWebhook'),
  ...require('./functions/setupAuth')
};