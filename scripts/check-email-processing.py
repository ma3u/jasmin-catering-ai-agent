#!/usr/bin/env python3
"""
Check if test email was received and processed
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from datetime import datetime, timedelta
from core.email_processor import EmailProcessor
from config.settings import EMAIL_CONFIG

def check_recent_emails():
    """Check for recent emails in the inbox"""
    
    print("🔍 Checking for recent emails to ma3u-test@email.de...")
    print(f"📧 Using email: {EMAIL_CONFIG['address']}")
    print(f"📬 Filtering by alias: {EMAIL_CONFIG['alias']}")
    
    try:
        processor = EmailProcessor()
        
        # Connect and check for recent emails
        print("\n📥 Fetching recent catering emails...")
        emails = processor.fetch_catering_emails(limit=10)
        
        if not emails:
            print("❌ No catering emails found")
            return
            
        print(f"\n✅ Found {len(emails)} catering emails:")
        
        # Look for our test email
        test_subject = "Catering Anfrage für Firmenevent - Test"
        found_test = False
        
        for i, email in enumerate(emails, 1):
            print(f"\n{i}. Subject: {email['subject']}")
            print(f"   From: {email['from']}")
            print(f"   Time: {email.get('received_time', 'Unknown')}")
            
            if test_subject in email['subject']:
                found_test = True
                print("   ✅ THIS IS OUR TEST EMAIL!")
                print(f"   Body preview: {email['body'][:200]}...")
                
        if found_test:
            print("\n🎉 Test email was successfully received!")
            print("📲 Check Slack channels for processing results:")
            print("   - #email-requests-and-response")
            print("   - #jasmin-logs")
        else:
            print("\n⚠️  Test email not found yet")
            print("   The Container Apps job runs every 5 minutes")
            print("   Email may still be in transit or waiting for next job run")
            
    except Exception as e:
        print(f"\n❌ Error checking emails: {e}")
        print("   Make sure EMAIL_CONFIG is properly set in .env")

if __name__ == "__main__":
    check_recent_emails()