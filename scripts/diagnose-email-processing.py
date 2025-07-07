#!/usr/bin/env python3
"""
Diagnose email processing issue - why emails are processed multiple times
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import imaplib
import email
from datetime import datetime
from config.settings import EMAIL_CONFIG

def diagnose_email_issue():
    """Check what emails are being found by the filter"""
    
    print("🔍 Diagnosing Email Processing Issue")
    print("="*60)
    print(f"📧 Email account: {EMAIL_CONFIG['address']}")
    print(f"🏷️  Alias filter: {EMAIL_CONFIG['alias']}")
    print("="*60)
    
    try:
        # Connect to IMAP
        mail = imaplib.IMAP4_SSL(EMAIL_CONFIG['imap_server'], EMAIL_CONFIG['imap_port'])
        mail.login(EMAIL_CONFIG['address'], EMAIL_CONFIG['password'])
        mail.select('inbox')
        
        # Search for today's emails TO the alias
        today = datetime.now().strftime("%d-%b-%Y")
        print(f"\n📅 Searching for emails since: {today}")
        print(f"🔎 Filter: TO \"{EMAIL_CONFIG['alias']}\"")
        
        status, messages = mail.search(None, f'(TO "{EMAIL_CONFIG["alias"]}") (SINCE "{today}")')
        
        if status == 'OK':
            email_ids = messages[0].split()
            print(f"\n📬 Found {len(email_ids)} emails matching the filter")
            
            if email_ids:
                print("\nEmail Details:")
                print("-"*80)
                
                for idx, email_id in enumerate(email_ids[-10:], 1):  # Last 10 emails
                    status, msg_data = mail.fetch(email_id, '(RFC822)')
                    if status == 'OK':
                        email_body = msg_data[0][1]
                        email_message = email.message_from_bytes(email_body)
                        
                        # Get TO header
                        to_header = email_message.get('To', 'Unknown')
                        delivered_to = email_message.get('Delivered-To', 'Unknown')
                        
                        print(f"\n{idx}. Email ID: {email_id.decode()}")
                        print(f"   From: {email_message['From']}")
                        print(f"   To: {to_header}")
                        print(f"   Delivered-To: {delivered_to}")
                        print(f"   Subject: {email_message['Subject']}")
                        print(f"   Date: {email_message['Date']}")
                        print(f"   Message-ID: {email_message.get('Message-ID', 'None')}")
                        
                        # Check if this is a response email
                        if 'Re:' in str(email_message['Subject']):
                            print("   ⚠️  This is a RESPONSE email (has 'Re:' in subject)")
                
                print("-"*80)
        
        # Also check for emails FROM the alias
        print(f"\n🔎 Checking emails FROM \"{EMAIL_CONFIG['alias']}\"...")
        status2, messages2 = mail.search(None, f'(FROM "{EMAIL_CONFIG["alias"]}") (SINCE "{today}")')
        
        if status2 == 'OK':
            email_ids2 = messages2[0].split()
            print(f"📤 Found {len(email_ids2)} emails sent FROM the alias")
        
        # Check UNSEEN emails
        print(f"\n🔎 Checking UNSEEN emails...")
        status3, messages3 = mail.search(None, '(UNSEEN)')
        
        if status3 == 'OK':
            email_ids3 = messages3[0].split()
            print(f"👁️  Found {len(email_ids3)} unread emails")
        
        mail.close()
        mail.logout()
        
        print("\n💡 DIAGNOSIS:")
        print("-"*60)
        print("The system is finding and processing emails every 5 minutes because:")
        print("1. It searches for ALL emails TO the alias from today")
        print("2. It doesn't track which emails were already processed")
        print("3. Response emails might be matching the filter if they're TO the alias")
        print("\n🔧 SOLUTIONS:")
        print("1. Mark emails as read/processed after handling")
        print("2. Track processed email IDs in a database or file")
        print("3. Filter out response emails (subjects starting with 'Re:')")
        print("4. Use UNSEEN flag to only process new emails")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")

if __name__ == "__main__":
    diagnose_email_issue()