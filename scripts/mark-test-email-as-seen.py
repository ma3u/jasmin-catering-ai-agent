#!/usr/bin/env python3
"""
Mark the test email as SEEN to stop repeated processing
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import imaplib
from config.settings import EMAIL_CONFIG

def mark_test_email_as_seen():
    """Mark the test email as seen to stop processing"""
    
    print("🔧 Marking test email as SEEN to stop repeated processing")
    print("="*60)
    
    try:
        # Connect to IMAP
        mail = imaplib.IMAP4_SSL(EMAIL_CONFIG['imap_server'], EMAIL_CONFIG['imap_port'])
        mail.login(EMAIL_CONFIG['address'], EMAIL_CONFIG['password'])
        mail.select('inbox')
        
        # Search for the test email
        status, messages = mail.search(None, f'(TO "{EMAIL_CONFIG["alias"]}")')
        
        if status == 'OK':
            email_ids = messages[0].split()
            print(f"📬 Found {len(email_ids)} emails TO {EMAIL_CONFIG['alias']}")
            
            # Mark all as SEEN
            for email_id in email_ids:
                result = mail.store(email_id, '+FLAGS', '\\Seen')
                print(f"✅ Marked email {email_id.decode()} as SEEN")
            
            print(f"\n✅ Marked {len(email_ids)} emails as SEEN")
            print("🛑 These emails will not be processed again")
        
        mail.close()
        mail.logout()
        
        print("\n✅ Done! The repeated processing should stop now.")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")

if __name__ == "__main__":
    mark_test_email_as_seen()