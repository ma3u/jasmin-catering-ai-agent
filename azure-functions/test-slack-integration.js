#!/usr/bin/env node

/**
 * Test Slack Integration for Azure Functions
 * Tests the SlackNotifier service with your actual Slack app
 */

const { WebClient } = require('@slack/web-api');

// Configuration
const config = {
  // Your Slack Bot Token (get from Slack App OAuth & Permissions)
  slackToken: process.env.SLACK_TOKEN || 'xoxb-YOUR-SLACK-BOT-TOKEN',
  channel: process.env.SLACK_CHANNEL || 'gmail-inbox',
  // Your Slack App ID for verification
  appId: 'A0931KMSEEL'
};

console.log('🧪 Testing Slack Integration for Jasmin Catering AI Agent');
console.log('================================================');

async function testSlackConnection() {
  console.log('\n📡 Testing Slack API Connection...');
  
  try {
    const slack = new WebClient(config.slackToken);
    
    // Test 1: Verify API connection
    const auth = await slack.auth.test();
    console.log('✅ Slack API Connection Success');
    console.log(`   App: ${auth.team} (${auth.team_id})`);
    console.log(`   Bot: ${auth.user} (${auth.user_id})`);
    console.log(`   URL: ${auth.url}`);
    
    return slack;
  } catch (error) {
    console.log('❌ Slack API Connection Failed');
    console.log(`   Error: ${error.message}`);
    
    if (error.message.includes('invalid_auth')) {
      console.log('   💡 Check your SLACK_TOKEN - should start with xoxb-');
    }
    
    throw error;
  }
}

async function testChannelAccess(slack) {
  console.log('\n📋 Testing Channel Access...');
  
  try {
    // Get channel info
    const channelInfo = await slack.conversations.info({
      channel: config.channel
    });
    
    console.log('✅ Channel Access Success');
    console.log(`   Channel: #${channelInfo.channel.name} (${channelInfo.channel.id})`);
    console.log(`   Members: ${channelInfo.channel.num_members || 'Unknown'}`);
    
    return channelInfo.channel.id;
  } catch (error) {
    console.log('❌ Channel Access Failed');
    console.log(`   Error: ${error.message}`);
    
    if (error.message.includes('channel_not_found')) {
      console.log('   💡 Make sure the bot is added to #gmail-inbox channel');
      console.log('   💡 In Slack, type: /invite @YasminCatering');
    }
    
    throw error;
  }
}

async function testSimpleMessage(slack, channelId) {
  console.log('\n💬 Testing Simple Message...');
  
  try {
    const result = await slack.chat.postMessage({
      channel: channelId,
      text: '🧪 Azure Functions Test Message',
      username: 'Jasmin Catering Bot'
    });
    
    console.log('✅ Simple Message Success');
    console.log(`   Message TS: ${result.ts}`);
    console.log(`   Channel: ${result.channel}`);
    
    return result;
  } catch (error) {
    console.log('❌ Simple Message Failed');
    console.log(`   Error: ${error.message}`);
    throw error;
  }
}

async function testCateringInquiryMessage(slack, channelId) {
  console.log('\n🍽️ Testing Catering Inquiry Format...');
  
  // Simulate a parsed email like your Azure Function would create
  const mockEmail = {
    id: 'test-email-123',
    from: 'customer@example.com',
    subject: 'Wedding catering for 120 guests',
    date: new Date().toISOString(),
    bodyText: 'Hallo, wir benötigen Catering für unsere Hochzeit am 15.03.2025 für 120 Personen in Berlin-Mitte...',
    guestCount: 120,
    eventDate: '15.03.2025'
  };
  
  // Build the same blocks your SlackNotifier would create
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
          text: `*From:*\n${mockEmail.from}`
        },
        {
          type: 'mrkdwn',
          text: `*Subject:*\n${mockEmail.subject}`
        }
      ]
    },
    {
      type: 'section',
      fields: [
        {
          type: 'mrkdwn',
          text: `*Guest Count:*\n${mockEmail.guestCount} people`
        },
        {
          type: 'mrkdwn',
          text: `*Event Date:*\n${mockEmail.eventDate}`
        }
      ]
    },
    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: `*Preview:*\n\`\`\`${mockEmail.bodyText.substring(0, 200)}...\`\`\``
      }
    },
    {
      type: 'context',
      elements: [
        {
          type: 'mrkdwn',
          text: '🧪 This is a test message from Azure Functions'
        }
      ]
    },
    {
      type: 'actions',
      elements: [
        {
          type: 'button',
          text: {
            type: 'plain_text',
            text: '📧 View in Gmail',
            emoji: true
          },
          url: `https://mail.google.com/mail/u/0/#inbox/${mockEmail.id}`,
          style: 'primary'
        },
        {
          type: 'button',
          text: {
            type: 'plain_text',
            text: '🤖 Process with AI',
            emoji: true
          },
          value: mockEmail.id,
          action_id: 'process_with_ai'
        }
      ]
    }
  ];
  
  try {
    const result = await slack.chat.postMessage({
      channel: channelId,
      text: `New catering inquiry from ${mockEmail.from}`,
      blocks: blocks
    });
    
    console.log('✅ Catering Inquiry Message Success');
    console.log(`   Message TS: ${result.ts}`);
    console.log(`   Rich formatting: ${result.message.blocks ? 'Yes' : 'No'}`);
    
    return result;
  } catch (error) {
    console.log('❌ Catering Inquiry Message Failed');
    console.log(`   Error: ${error.message}`);
    throw error;
  }
}

async function testAzureFunctionEndpoint() {
  console.log('\n🔧 Testing Azure Function Endpoint...');
  
  const functionUrl = 'https://jasmin-gmail-functions.azurewebsites.net/api/testGmailConnection';
  
  try {
    const response = await fetch(functionUrl);
    const data = await response.json();
    
    if (response.ok) {
      console.log('✅ Azure Function Endpoint Success');
      console.log(`   Status: ${response.status}`);
      console.log(`   Connected: ${data.connected}`);
      console.log(`   Email: ${data.profile?.emailAddress || 'Not available'}`);
    } else {
      console.log('⚠️ Azure Function Endpoint Warning');
      console.log(`   Status: ${response.status}`);
      console.log(`   Error: ${data.error || 'Unknown error'}`);
    }
  } catch (error) {
    console.log('❌ Azure Function Endpoint Failed');
    console.log(`   Error: ${error.message}`);
    console.log('   💡 Make sure Azure Functions are deployed and running');
  }
}

async function runAllTests() {
  console.log(`📱 App ID: ${config.appId}`);
  console.log(`📧 Channel: #${config.channel}`);
  console.log(`🔑 Token: ${config.slackToken.substring(0, 15)}...`);
  
  try {
    // Test 1: Basic Slack connection
    const slack = await testSlackConnection();
    
    // Test 2: Channel access
    const channelId = await testChannelAccess(slack);
    
    // Test 3: Simple message
    await testSimpleMessage(slack, channelId);
    
    // Test 4: Rich catering inquiry message
    await testCateringInquiryMessage(slack, channelId);
    
    // Test 5: Azure Function endpoint
    await testAzureFunctionEndpoint();
    
    console.log('\n🎉 All Tests Completed!');
    console.log('✅ Your Slack integration is ready for Azure Functions');
    
  } catch (error) {
    console.log('\n❌ Test Suite Failed');
    console.log(`Final Error: ${error.message}`);
    process.exit(1);
  }
}

// Check if token is provided
if (!config.slackToken || config.slackToken === 'xoxb-YOUR-SLACK-BOT-TOKEN') {
  console.log('❌ SLACK_TOKEN not configured');
  console.log('');
  console.log('Please set your Slack Bot Token:');
  console.log('export SLACK_TOKEN=xoxb-your-actual-token');
  console.log('');
  console.log('Or edit this file and replace the token directly.');
  process.exit(1);
}

// Run the tests
runAllTests().catch(console.error);
