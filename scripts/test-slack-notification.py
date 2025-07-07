#!/usr/bin/env python3
"""
Test the Slack notification with a simulated email
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from datetime import datetime
from core.slack_notifier import SlackNotifier

def test_slack_notification():
    """Test Slack notification with a long email"""
    
    # Create a test email with a long body
    test_email = {
        'id': f'test-{datetime.now().strftime("%Y%m%d%H%M%S")}',
        'from': 'max.mustermann@beispiel-gmbh.de',
        'subject': 'Catering Anfrage für Firmenevent - Slack Test',
        'body': """Sehr geehrtes Jasmin Catering Team,

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

**Budget und Zeitplan:**
- Budget: 3.000-4.000 EUR gesamt
- Aufbauzeit: ab 16:00 Uhr möglich
- Abbau: bis spätestens 24:00 Uhr

**Bisherige Erfahrungen:**
Wir haben bereits mehrere erfolgreiche Events mit verschiedenen Catering-Anbietern durchgeführt. Besonders wichtig sind uns:
- Pünktlichkeit und Zuverlässigkeit
- Qualität und Frische der Speisen
- Professionelles und freundliches Service-Personal
- Flexibilität bei kurzfristigen Änderungen

Bitte senden Sie uns ein detailliertes Angebot mit:
- Verschiedenen Menüoptionen (Basic, Premium, Deluxe)
- Preisen pro Person für jede Option
- Auflistung aller inkludierten Leistungen
- Zusatzleistungen und deren Preise
- Stornierungsbedingungen
- Referenzen ähnlicher Events

Für Rückfragen stehe ich Ihnen gerne zur Verfügung:
- Telefon: +49 30 12345678
- Mobil: +49 172 9876543
- E-Mail: max.mustermann@beispiel-gmbh.de

Wir freuen uns auf Ihre Rückmeldung und ein köstliches Catering!

Mit freundlichen Grüßen
Max Mustermann
Event Manager
Beispiel GmbH
Musterstraße 123
10115 Berlin"""
    }
    
    print("🧪 Testing Slack notification with long email body...")
    print(f"📏 Email body length: {len(test_email['body'])} characters")
    
    try:
        # Initialize Slack notifier
        slack = SlackNotifier()
        
        # Post the test email
        print("\n📤 Posting to Slack...")
        success = slack.post_email_request(test_email)
        
        if success:
            print("✅ Successfully posted to Slack!")
            print("\n🔍 Check your Slack channel #email-requests-and-response")
            print("   The full email content should now be visible (not truncated)")
        else:
            print("❌ Failed to post to Slack")
            print("   Check your Slack configuration in config/settings.py")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\n💡 Make sure you have set up:")
        print("   - SLACK_BOT_TOKEN in your environment")
        print("   - SLACK_CHANNEL_ID in your environment")
        print("   - Proper Slack app permissions")

if __name__ == "__main__":
    test_slack_notification()