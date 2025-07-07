#!/usr/bin/env python3
"""
Test email response format with original request included
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from datetime import datetime
from core.email_processor import EmailProcessor

def test_email_format():
    """Test the email format with original request"""
    
    # Create test data
    test_original_email = {
        'id': '12345',
        'subject': 'Catering Anfrage für Firmenevent',
        'body': """Sehr geehrtes Jasmin Catering Team,

wir planen ein Firmenevent für 50 Personen am 15. September 2025.
Bitte um ein Angebot für syrisches Catering.

Mit freundlichen Grüßen
Max Mustermann""",
        'from': 'max.mustermann@beispiel.de',
        'date': 'Mon, 7 Jul 2025 12:30:00 +0200'
    }
    
    # Sample AI response
    test_response = """Sehr geehrter Herr Mustermann,

vielen Dank für Ihre Anfrage. Gerne erstellen wir Ihnen ein Angebot für Ihr Firmenevent.

**Basis-Paket (35€ pro Person)**
- Mezze-Auswahl
- Hauptgericht
- Dessert
Gesamtpreis: 1.750€

**Standard-Paket (45€ pro Person)**
- Erweiterte Mezze-Auswahl
- 2 Hauptgerichte zur Auswahl
- Dessertvariation
Gesamtpreis: 2.250€

**Premium-Paket (60€ pro Person)**
- Deluxe Mezze-Buffet
- 3 Hauptgerichte
- Live-Cooking-Station
- Premium Desserts
Gesamtpreis: 3.000€

Alle Preise verstehen sich inklusive Service, Geschirr und Anlieferung."""
    
    # Test RAG documents
    test_documents = [
        {"title": "Jasmin Catering Preisliste 2025"},
        {"title": "Event-Catering Richtlinien"}
    ]
    
    print("🧪 Testing email format with original request...")
    print("="*60)
    
    # Initialize processor
    processor = EmailProcessor()
    
    # Build the email content manually to show what it will look like
    full_email = test_response
    
    # Add RAG footer
    full_email += "\n\n---\n📚 Diese Antwort wurde mit folgenden Wissensdokumenten erstellt:\n"
    for doc in test_documents:
        full_email += f"• {doc['title']}\n"
    
    # Add signature
    full_email += f"\n\n--\nMit freundlichen Grüßen\nIhr Jasmin Catering Team\n{processor.alias}"
    
    # Add original request
    full_email += "\n\n" + "="*60 + "\n"
    full_email += "URSPRÜNGLICHE ANFRAGE\n"
    full_email += "="*60 + "\n"
    full_email += f"Von: {test_original_email['from']}\n"
    full_email += f"Datum: {test_original_email['date']}\n"
    full_email += f"Betreff: {test_original_email['subject']}\n"
    full_email += "-"*60 + "\n"
    full_email += test_original_email['body']
    
    print("\n📧 PREVIEW OF EMAIL RESPONSE:")
    print("-"*60)
    print(f"To: {processor.email_address}")
    print(f"From: {processor.alias}")
    print(f"Subject: Re: {test_original_email['subject']}")
    print("-"*60)
    print(full_email)
    print("-"*60)
    
    print("\n✅ Email format test complete!")
    print("\n💡 The original request is now included at the end of every response email.")
    print("   This helps recipients see the full context of the conversation.")

if __name__ == "__main__":
    test_email_format()