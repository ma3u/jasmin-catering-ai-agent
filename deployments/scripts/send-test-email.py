#!/usr/bin/env python3
import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Email configuration
sender = os.getenv('WEBDE_EMAIL_ALIAS', 'ma3u-test@email.de')
password = os.getenv('WEBDE_APP_PASSWORD')
recipient = os.getenv('WEBDE_EMAIL_ALIAS', 'ma3u-test@email.de')

# Create test email
msg = MIMEMultipart()
msg['From'] = sender
msg['To'] = recipient
msg['Subject'] = f'Catering Anfrage - Test {datetime.now().strftime("%Y-%m-%d %H:%M")}'

# Email body with a realistic catering inquiry
body = """Sehr geehrtes Jasmin Catering Team,

wir planen eine Firmenveranstaltung für 45 Personen am 15. Juli 2025 in unseren Büroräumen in Berlin-Mitte.

Wir interessieren uns für Ihr syrisches Catering-Angebot. Könnten Sie uns bitte ein Angebot zusenden?

Details zur Veranstaltung:
- Datum: 15. Juli 2025
- Uhrzeit: 18:00 - 22:00 Uhr
- Anzahl Gäste: 45 Personen
- Location: Unter den Linden 21, Berlin
- Budget: 40€ pro Person

Wir hätten gerne eine Auswahl an vegetarischen und veganen Optionen.

Mit freundlichen Grüßen,
Anna Schmidt
Event Manager
Test Company GmbH
Tel: 030-12345678
"""

msg.attach(MIMEText(body, 'plain'))

# Send email
try:
    server = smtplib.SMTP('smtp.web.de', 587)
    server.starttls()
    server.login(sender, password)
    server.send_message(msg)
    server.quit()
    print(f"✅ Test email sent successfully to {recipient}")
    print(f"📧 Subject: {msg['Subject']}")
except Exception as e:
    print(f"❌ Error sending email: {str(e)}")