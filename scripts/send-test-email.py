#!/usr/bin/env python3
"""
Send a test email to ma3u-test@email.de for testing Slack integration
"""

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def send_test_email():
    """Send a test catering inquiry email"""
    
    # Email configuration
    smtp_server = "smtp.web.de"
    smtp_port = 587
    sender_email = "ma3u-test@email.de"
    sender_password = os.getenv('WEBDE_APP_PASSWORD')
    recipient_email = "ma3u-test@email.de"
    
    if not sender_password:
        print("❌ Error: WEBDE_APP_PASSWORD not found in .env file")
        return False
    
    # Create a detailed test email
    subject = f"Catering Anfrage für Firmenevent - Test {datetime.now().strftime('%Y-%m-%d %H:%M')}"
    
    body = """Sehr geehrtes Jasmin Catering Team,

wir planen ein großes Firmenevent und sind sehr an Ihrem syrischen Fusion-Catering interessiert.

**Veranstaltungsdetails:**
- Datum: 15. September 2025
- Uhrzeit: 18:00 - 23:00 Uhr
- Ort: Alexanderplatz 1, 10178 Berlin
- Anzahl Gäste: 75 Personen
- Anlass: Produktlaunch und Kundenveranstaltung

**Gewünschte Leistungen:**
- Fingerfood und warme Speisen
- Vegetarische und vegane Optionen (ca. 30% der Gäste)
- Halal-Zertifizierung wenn möglich
- Getränke (alkoholfrei)
- Service-Personal
- Geschirr und Besteck

**Besondere Wünsche:**
- Live-Cooking-Station für Falafel oder Shawarma wäre toll
- Allergikerfreundliche Kennzeichnung der Speisen
- Möglichkeit für eine kurze Präsentation der syrischen Küche

Bitte senden Sie uns ein detailliertes Angebot mit:
- Verschiedenen Menüoptionen
- Preisen pro Person
- Zusatzleistungen
- Stornierungsbedingungen

Wir freuen uns auf Ihre Rückmeldung und ein köstliches Catering!

Mit freundlichen Grüßen
Max Mustermann
Event Manager
Beispiel GmbH
Tel: +49 30 12345678
max.mustermann@beispiel-gmbh.de"""
    
    # Create message
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        # Send email
        print(f"📧 Sending test email to {recipient_email}...")
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        
        text = msg.as_string()
        server.sendmail(sender_email, recipient_email, text)
        server.quit()
        
        print(f"✅ Test email sent successfully!")
        print(f"📬 Subject: {subject}")
        print(f"📏 Body length: {len(body)} characters")
        print("\n🔍 Check your Slack channels:")
        print("   - #email-requests-and-response for the full inquiry")
        print("   - #jasmin-logs for processing logs")
        
        return True
        
    except Exception as e:
        print(f"❌ Error sending email: {e}")
        return False

if __name__ == "__main__":
    send_test_email()