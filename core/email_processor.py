"""
Email processor for Jasmin Catering
"""

import imaplib
import email
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
from typing import List, Dict, Optional
from config.settings import EMAIL_CONFIG


class EmailProcessor:
    """Handle email operations for Jasmin Catering"""
    
    def __init__(self):
        self.imap_server = EMAIL_CONFIG['imap_server']
        self.imap_port = EMAIL_CONFIG['imap_port']
        self.smtp_server = EMAIL_CONFIG['smtp_server']
        self.smtp_port = EMAIL_CONFIG['smtp_port']
        self.email_address = EMAIL_CONFIG['address']
        self.password = EMAIL_CONFIG['password']
        self.alias = EMAIL_CONFIG['alias']
        
    def fetch_catering_emails(self, limit: int = 5) -> List[Dict]:
        """Fetch recent UNSEEN catering-related emails"""
        emails = []
        processed_email_ids = []
        
        try:
            # Connect to IMAP
            mail = imaplib.IMAP4_SSL(self.imap_server, self.imap_port)
            mail.login(self.email_address, self.password)
            mail.select('inbox')
            
            # Search for UNSEEN emails sent TO the alias
            # This prevents processing the same email multiple times
            status, messages = mail.search(None, f'(UNSEEN) (TO "{self.alias}")')
            
            if status == 'OK':
                email_ids = messages[0].split()
                # Get last N emails
                email_ids = email_ids[-limit:] if len(email_ids) > limit else email_ids
                
                for email_id in email_ids:
                    status, msg_data = mail.fetch(email_id, '(RFC822)')
                    if status == 'OK':
                        email_body = msg_data[0][1]
                        email_message = email.message_from_bytes(email_body)
                        
                        # Extract subject
                        subject = self._decode_subject(email_message['Subject'])
                        
                        # Skip response emails (already processed)
                        if subject.startswith('Re:') or subject.startswith('RE:'):
                            print(f"⏭️  Skipping response email: {subject}")
                            # Mark as seen anyway to avoid reprocessing
                            mail.store(email_id, '+FLAGS', '\\Seen')
                            continue
                        
                        # Extract body
                        body = self._extract_body(email_message)
                        
                        # Check if catering-related
                        if self._is_catering_email(subject, body):
                            emails.append({
                                'id': email_id.decode(),
                                'subject': subject,
                                'body': body,
                                'from': email_message['From'],
                                'date': email_message['Date']
                            })
                            processed_email_ids.append(email_id)
                        else:
                            # Mark non-catering emails as seen to avoid reprocessing
                            mail.store(email_id, '+FLAGS', '\\Seen')
                
                # Mark all processed catering emails as SEEN after successful processing
                # This happens in mark_emails_as_processed() method
                self._temp_email_ids = processed_email_ids
            
            mail.close()
            mail.logout()
            
        except Exception as e:
            print(f"Email fetch error: {e}")
        
        return emails
    
    def send_response(self, to_address: str, subject: str, response_text: str, 
                     rag_documents: List[Dict] = None, original_email: Dict = None) -> bool:
        """Send email response with original request appended"""
        try:
            msg = MIMEMultipart()
            msg['From'] = self.alias
            msg['To'] = to_address
            msg['Subject'] = f"Re: {subject}"
            
            # Add RAG footer if documents provided
            if rag_documents:
                rag_footer = "\n\n---\n📚 Diese Antwort wurde mit folgenden Wissensdokumenten erstellt:\n"
                for doc in rag_documents:
                    rag_footer += f"• {doc['title']}\n"
                response_text += rag_footer
            
            # Add signature
            response_text += f"\n\n--\nMit freundlichen Grüßen\nIhr Jasmin Catering Team\n{self.alias}"
            
            # Add original request at the end
            if original_email:
                response_text += "\n\n" + "="*60 + "\n"
                response_text += "URSPRÜNGLICHE ANFRAGE\n"
                response_text += "="*60 + "\n"
                response_text += f"Von: {original_email.get('from', 'Unbekannt')}\n"
                response_text += f"Datum: {original_email.get('date', 'Unbekannt')}\n"
                response_text += f"Betreff: {original_email.get('subject', 'Kein Betreff')}\n"
                response_text += "-"*60 + "\n"
                response_text += original_email.get('body', 'Kein Inhalt')
            
            msg.attach(MIMEText(response_text, 'plain'))
            
            # Send email
            server = smtplib.SMTP(self.smtp_server, self.smtp_port)
            server.starttls()
            server.login(self.alias, self.password)
            server.send_message(msg)
            server.quit()
            
            return True
            
        except Exception as e:
            print(f"Email send error: {e}")
            return False
    
    def _decode_subject(self, subject: str) -> str:
        """Decode email subject if encoded"""
        if not subject:
            return "No Subject"
            
        try:
            decoded = email.header.decode_header(subject)[0]
            if decoded[1]:
                return decoded[0].decode(decoded[1])
            return str(decoded[0])
        except:
            return str(subject)
    
    def _extract_body(self, email_message) -> str:
        """Extract plain text body from email"""
        body = ""
        
        if email_message.is_multipart():
            for part in email_message.walk():
                if part.get_content_type() == "text/plain":
                    body = part.get_payload(decode=True).decode()
                    break
        else:
            body = email_message.get_payload(decode=True).decode()
        
        return body
    
    def _is_catering_email(self, subject: str, body: str) -> bool:
        """Check if email is catering-related"""
        keywords = [
            'catering', 'fest', 'feier', 'hochzeit', 'geburtstag', 
            'event', 'mittagessen', 'lunch', 'dinner', 'buffet',
            'gäste', 'personen', 'büro', 'firma'
        ]
        
        text = (subject + " " + body).lower()
        return any(keyword in text for keyword in keywords)
    
    def mark_email_as_processed(self, email_id: str) -> bool:
        """Mark an email as SEEN to prevent reprocessing"""
        try:
            mail = imaplib.IMAP4_SSL(self.imap_server, self.imap_port)
            mail.login(self.email_address, self.password)
            mail.select('inbox')
            
            # Mark email as SEEN
            mail.store(email_id.encode(), '+FLAGS', '\\Seen')
            
            mail.close()
            mail.logout()
            
            print(f"✅ Marked email {email_id} as processed")
            return True
            
        except Exception as e:
            print(f"❌ Error marking email as processed: {e}")
            return False