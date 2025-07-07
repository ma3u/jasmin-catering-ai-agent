#!/usr/bin/env python3
"""
Send a test catering inquiry email from matthias.buchhorn@web.de to ma3u-test@email.de
"""

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv
import random

# Load environment variables
load_dotenv()

def send_catering_inquiry():
    """Send a realistic catering inquiry email"""
    
    # Email configuration
    smtp_server = "smtp.web.de"
    smtp_port = 587
    sender_email = "matthias.buchhorn@web.de"
    sender_password = os.getenv('WEBDE_APP_PASSWORD')
    recipient_email = "ma3u-test@email.de"
    
    if not sender_password:
        print("❌ Error: WEBDE_APP_PASSWORD not found in .env file")
        return False
    
    # Generate random event details
    event_date = datetime.now() + timedelta(days=random.randint(30, 90))
    guest_count = random.choice([25, 40, 60, 80, 120, 150])
    
    # Create a realistic catering inquiry
    subject = f"Catering-Anfrage für {event_date.strftime('%d.%m.%Y')} - {guest_count} Personen"
    
    body = f"""Sehr geehrtes Jasmin Catering Team,

ich habe von Kollegen viel Gutes über Ihr syrisches Fusion-Catering gehört und möchte gerne eine Anfrage für eine Veranstaltung stellen.

**Details zur Veranstaltung:**
- Datum: {event_date.strftime('%d. %B %Y')}
- Uhrzeit: 19:00 - 24:00 Uhr
- Ort: Prenzlauer Berg, Berlin (genaue Adresse folgt)
- Anzahl der Gäste: ca. {guest_count} Personen
- Anlass: Geburtstagsfeier (50. Geburtstag)

**Unsere Vorstellungen:**
- Buffet mit syrischen Spezialitäten
- Mix aus kalten und warmen Speisen
- Vegetarische/vegane Optionen für etwa 20% der Gäste
- 2 Gäste mit Glutenunverträglichkeit
- 1 Gast mit Nussallergie
- Gerne auch klassische Desserts wie Baklava

**Zusätzliche Leistungen:**
- Geschirr, Besteck und Gläser benötigt
- Servicepersonal für Buffetbetreuung
- Getränke (nur alkoholfreie Optionen)

**Budget:** 
Wir haben ein Budget von etwa {35 + random.randint(0, 10)}€ pro Person eingeplant.

**Fragen:**
1. Können Sie an diesem Datum catern?
2. Welche Menüvorschläge hätten Sie für diese Gruppengröße?
3. Ist eine Anlieferung nach Prenzlauer Berg möglich?
4. Wie sind Ihre Stornierungsbedingungen?

Ich würde mich über ein detailliertes Angebot mit verschiedenen Menüoptionen freuen. Gerne können wir auch telefonisch die Details besprechen.

Mit freundlichen Grüßen

Sandra Meier
Tel: +49 170 {random.randint(1000000, 9999999)}
sandra.meier{random.randint(1, 99)}@gmail.com"""
    
    # Create message
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain', 'utf-8'))
    
    try:
        # Send email
        print(f"📧 Sending catering inquiry email...")
        print(f"   From: {sender_email}")
        print(f"   To: {recipient_email}")
        print(f"   Subject: {subject}")
        
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        
        text = msg.as_string()
        server.sendmail(sender_email, recipient_email, text)
        server.quit()
        
        print(f"\n✅ Catering inquiry sent successfully!")
        print(f"📅 Event date: {event_date.strftime('%d.%m.%Y')}")
        print(f"👥 Guest count: {guest_count}")
        print(f"📏 Email length: {len(body)} characters")
        print("\n🔍 The email should be processed by the Logic App within 5 minutes")
        print("   Check Azure Portal or use monitoring scripts to track processing")
        
        return True
        
    except Exception as e:
        print(f"❌ Error sending email: {e}")
        print(f"   Make sure the WEBDE_APP_PASSWORD in .env is correct")
        return False

if __name__ == "__main__":
    send_catering_inquiry()