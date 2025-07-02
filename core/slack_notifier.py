"""
Simplified Slack notifier for Jasmin Catering
"""

import requests
import json
from datetime import datetime
from typing import Dict, Optional, Any
from config.settings import SLACK_CONFIG


class SlackNotifier:
    """Handle Slack notifications"""
    
    def __init__(self):
        self.token = SLACK_CONFIG['bot_token']
        self.email_channel = SLACK_CONFIG['email_channel_id']
        self.log_channel = SLACK_CONFIG['log_channel_id']
        self.headers = {
            'Authorization': f'Bearer {self.token}',
            'Content-Type': 'application/json'
        }
    
    def post_email_request(self, email_data: Dict[str, Any]) -> bool:
        """Post incoming email to Slack"""
        blocks = [
            {
                "type": "header",
                "text": {"type": "plain_text", "text": "📧 New Catering Inquiry"}
            },
            {
                "type": "section",
                "fields": [
                    {"type": "mrkdwn", "text": f"*From:* {email_data.get('from', 'Unknown')}"},
                    {"type": "mrkdwn", "text": f"*Subject:* {email_data['subject']}"},
                    {"type": "mrkdwn", "text": f"*Time:* {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"},
                    {"type": "mrkdwn", "text": f"*ID:* {email_data.get('id', 'N/A')}"}
                ]
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*Message:*\n```{email_data['body'][:500]}...```"
                }
            }
        ]
        
        return self._post_message(self.email_channel, "📧 New Catering Inquiry", blocks)
    
    def post_ai_response(self, email_subject: str, response_info: Dict[str, Any]) -> bool:
        """Post AI response to Slack"""
        blocks = [
            {
                "type": "header",
                "text": {"type": "plain_text", "text": "🤖 AI Response Generated"}
            },
            {
                "type": "section",
                "fields": [
                    {"type": "mrkdwn", "text": f"*Subject:* Re: {email_subject}"},
                    {"type": "mrkdwn", "text": f"*Processing Time:* {response_info.get('processing_time', 'N/A')}"},
                    {"type": "mrkdwn", "text": f"*Documents Used:* {response_info.get('documents_used', 0)}"},
                    {"type": "mrkdwn", "text": f"*Status:* ✅ Sent"}
                ]
            }
        ]
        
        # Add pricing if available
        if response_info.get('pricing'):
            pricing_text = "\n".join([f"• {pkg}: {price}" for pkg, price in response_info['pricing'].items()])
            blocks.append({
                "type": "section",
                "text": {"type": "mrkdwn", "text": f"*Pricing Offered:*\n{pricing_text}"}
            })
        
        return self._post_message(self.email_channel, "🤖 AI Response Generated", blocks)
    
    def log(self, message: str, level: str = "info", details: Optional[Dict] = None) -> bool:
        """Send log message to log channel"""
        emoji = {"info": "ℹ️", "success": "✅", "error": "❌", "warning": "⚠️"}.get(level, "📌")
        
        blocks = [
            {
                "type": "section",
                "text": {"type": "mrkdwn", "text": f"{emoji} *{message}*"}
            }
        ]
        
        if details:
            blocks.append({
                "type": "section",
                "text": {"type": "mrkdwn", "text": f"```{json.dumps(details, indent=2, ensure_ascii=False)}```"}
            })
        
        return self._post_message(self.log_channel, message, blocks)
    
    def _post_message(self, channel: str, text: str, blocks: list) -> bool:
        """Post message to Slack channel"""
        try:
            response = requests.post(
                'https://slack.com/api/chat.postMessage',
                headers=self.headers,
                json={'channel': channel, 'text': text, 'blocks': blocks}
            )
            return response.json().get('ok', False)
        except Exception as e:
            print(f"Slack error: {e}")
            return False