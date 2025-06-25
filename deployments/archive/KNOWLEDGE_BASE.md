# Jasmin Catering AI - Wissensdatenbank Dokumentation

## 📚 Übersicht der Vector Database Dokumente

Diese Datei dokumentiert alle Dokumente in der RAG-Wissensdatenbank für den Jasmin Catering AI-Agent.

### 🎯 Hauptdokumente (`deployments/documents/`)

#### 1. `catering-brief.md`
**Zweck:** Geschäftsprozess und 3-Angebote-System  
**Kategorie:** `process`  
**Inhalt:**
- Hauptziel der Automatisierung
- Google Form Anfrage-Prozess  
- 3 Package-System (Basis/Standard/Premium)
- Agent-Anforderungen
- Technische Plattform (Azure AI Foundry)
- Wichtige Geschäftsprinzipien

#### 2. `vegetarian-offer-template.md`  
**Zweck:** Menü-Optionen, Preise und Angebotsstruktur  
**Kategorie:** `menu`  
**Inhalt:**
- Firmeninformationen und Kontaktdaten
- Angebots-Header Template
- Komplette Fingerfood-Menü-Optionen
- Dessert-Auswahl (Malakieh, Baklava, etc.)
- Getränke-Optionen (alkoholisch/alkoholfrei)
- Service-Leistungen und Equipment
- Preisstruktur-Hinweise

#### 3. `email-template.md`
**Zweck:** Professionelle E-Mail-Kommunikation  
**Kategorien:** `communication`  
**Inhalt:**
- Standard Email-Vorlage für Angebote
- Strukturierte Informationsabfrage
- Instagram Marketing Integration
- Kommunikations-Stil Guidelines
- Follow-up Prozess
- Kontakt-Informationen Template

#### 4. `business-conditions.md`
**Zweck:** Geschäftsbedingungen und rechtliche Informationen  
**Kategorie:** `terms`  
**Inhalt:**
- Allgemeine Geschäftsbedingungen
- Stornierungsbedingungen (70% bei 48h)
- Zahlungsbedingungen (4 Wochen)
- Firmendaten (AL Armachi Salma Zaim Fadi GbR)
- Bankverbindung (KT Bank AG)
- Service-Bedingungen
- Qualitätsversprechen

### 📋 Template-Sammlung (`deployments/templates/`)

#### 5. `order-templates.md`
**Zweck:** Standardisierte Bestell- und Antwort-Templates  
**Kategorie:** `templates`  
**Inhalt:**
- Standard Auftragsbestätigung (Deutsch/Englisch)
- Anfrage-Antwort Template
- Fehlende Informationen Template
- Strukturierte Angebotspakete

#### 6. `response-examples.md`
**Zweck:** Praxisnahe Beispiele für verschiedene Event-Typen  
**Kategorie:** `examples`  
**Inhalt:**
- Firmenevent-Beispiel (80 Personen, Business Premium)
- Hochzeits-Beispiel (150 Personen, vegetarisch)
- Urgent Small Event (20 Personen, Express)
- Verschiedene Preiskategorien und Anpassungen

#### 7. `company-policies.md`
**Zweck:** Unternehmensrichtlinien und Service-Standards  
**Kategorie:** `policies`  
**Inhalt:**
- Business Information und Service Area
- Minimum Requirements (15-500 Personen)
- Preisstruktur (25-60+ EUR pro Person)
- Zahlungsbedingungen und Stornierungsrichtlinien
- Menü-Richtlinien und Diät-Anpassungen
- Service Standards und Qualitätsgarantien

### 📖 Projekt-Dokumentation

#### 8. `README.md` (Projektverzeichnis)
**Zweck:** Vollständige Systemdokumentation  
**Kategorie:** `documentation`  
**Inhalt:**
- Aktuelle Implementierung (Azure Logic Apps + AI Foundry)
- Projektstruktur und Architektur
- Deployment-Optionen und Monitoring
- Email-Processing-Flow mit Beispielen
- Troubleshooting und Next Steps

#### 9. `CLAUDE.md` (Projektverzeichnis)  
**Zweck:** AI-Agent Anweisungen und Best Practices  
**Kategorie:** `ai-guidance`  
**Inhalt:**
- Kritische Informationen (Region: Sweden Central)
- Deployment-Philosophie
- Email-Konfiguration
- Bekannte Probleme und Lösungen
- Architektur-Entscheidungen

## 🔍 RAG-System Nutzung

### Suchstrategie für AI-Agent:
1. **Event-Type-spezifisch:** Suche in `response-examples.md` nach ähnlichen Events
2. **Menü-Details:** Verwende exakte Beschreibungen aus `vegetarian-offer-template.md`
3. **Email-Format:** Befolge Struktur aus `email-template.md`
4. **Preisberechnung:** Orientiere dich an `company-policies.md` und `catering-brief.md`
5. **Geschäftsbedingungen:** Integriere Informationen aus `business-conditions.md`

### Qualitätssicherung:
- ✅ Alle Menü-Namen sind authentisch syrisch
- ✅ Preise entsprechen den Richtlinien (25-60+ EUR/Person)
- ✅ Kommunikation ist professionell und auf Deutsch
- ✅ Drei verschiedene Package-Levels werden angeboten
- ✅ Geschäftsbedingungen sind korrekt integriert

## 📊 Vector Database Struktur

```
jasmin-catering-knowledge (Index)
├── Kategorie: process (1 Dokument)
│   └── catering-brief.md
├── Kategorie: menu (1 Dokument)
│   └── vegetarian-offer-template.md  
├── Kategorie: communication (1 Dokument)
│   └── email-template.md
├── Kategorie: terms (1 Dokument)
│   └── business-conditions.md
├── Kategorie: templates (1 Dokument)
│   └── order-templates.md
├── Kategorie: examples (1 Dokument)
│   └── response-examples.md
├── Kategorie: policies (1 Dokument)
│   └── company-policies.md
├── Kategorie: documentation (1 Dokument)
│   └── README.md
└── Kategorie: ai-guidance (1 Dokument)
    └── CLAUDE.md
```

**Gesamt: 9 Dokumente in 9 Kategorien**

## 🚀 Deployment-Status

Alle Dokumente werden automatisch beim Ausführen von `setup-vector-db.sh` in die Azure AI Search Wissensdatenbank hochgeladen und sind für den RAG-gestützten AI-Agent verfügbar.

---
*Letzte Aktualisierung: Juni 2025*