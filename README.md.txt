# ✨ Projekt: Jasmin Catering AI Agent Lösung ✨

## 📝 Projektbeschreibung

Dieses Projekt zielt darauf ab, den Prozess der Bearbeitung von Kundenanfragen und der Erstellung von Angeboten für Jasmin Catering zu automatisieren und zu optimieren. Jasmin Catering ist ein familiengeführtes Unternehmen in Berlin, das Full-Service-Catering für Veranstaltungen mit 15 bis 500 Gästen anbietet, spezialisiert auf syrische Fusionsküche [1, 2]. Aktuell werden Anfragen über ein Formular (Website oder Google Form) erfasst [3, 4]. Basierend auf den gesammelten Informationen (wie Datum, Ort, Personenanzahl, Speisenwünsche, Budget etc. [3]) werden vom Caterer oder potenziell einem Agenten drei verschiedene Angebote/Pakete erstellt und per E-Mail versendet [3, 5, 6]. Die vorgeschlagene Lösung wird einen KI-Agenten nutzen, um die Effizienz und Skalierbarkeit dieses Anfrage- und Angebotsprozesses zu erhöhen. Der Agent soll in der Lage sein, aus den Anfrageinformationen automatisiert Angebotsvorschläge zu generieren [5] und die Kommunikation mit dem Kunden zu unterstützen.

## 🎯 Ziele

*   **Beschleunigung der Angebotserstellung:** Reduzierung der Bearbeitungszeit von der Anfrage bis zum Versand des Angebots. Derzeit wird ein Angebot innerhalb von 72 Stunden angestrebt [4].
*   **Automatisierung von Routineaufgaben:** Automatisches Extrahieren relevanter Informationen aus Kundenanfragen [3] und Generierung von strukturierten Angebotsvorschlägen [5, 6].
*   **Verbesserung der Effizienz:** Ermöglichung der Bearbeitung einer größeren Anzahl von Anfragen ohne proportionalen Anstieg des manuellen Aufwands.
*   **Integration:** Nahtlose Anbindung an die bestehenden oder erweiterbaren Anfrageformulare (Website-Formular, Google Form) [3, 4].
*   **Konsistenz:** Sicherstellung, dass Angebote und Kommunikation den definierten Standards und Vorlagen entsprechen [6-9].

## 🏗️ Umfang

**In-Scope:**

*   Erfassung von Anfragedaten aus einem bereitgestellten Formular (Google Form oder Website-Formular) [3, 4].
*   Extraktion und Verarbeitung der Schlüsselinformationen aus der Anfrage (Datum, Gästezahl, Ort, Speisen-/Getränkewünsche, diätetische Präferenzen wie vegetarisch/vegan, Budget etc.) [3, 7, 8].
*   Zugriff auf eine Wissensbasis mit Menüdetails, Paketstrukturen, Preisinformationen und Geschäftsbedingungen [5, 6, 10-16].
*   Generierung von Entwürfen für drei unterschiedliche Angebotsvarianten ("3 Angebote / Packages") basierend auf den Anfragedetails und der definierten Logik [3, 5, 6].
*   Formatierung der generierten Angebote in eine E-Mail, die der Vorlage entspricht [6-9].
*   Versand der Angebots-E-Mail an den Kunden.
*   Integration mit dem Claude AI API als Chat-Modell für die Verarbeitung natürlicher Sprache.

**Out-of-Scope (initial):**

*   Vollständige Konversation mit dem Kunden über den gesamten Buchungsprozess (z.B. Klärung von Details, Änderungen nach Versand des Angebots, Zahlungsabwicklung). Der Agent konzentriert sich zunächst auf den ersten Schritt: Anfrage -> Angebot.
*   Automatische Rechnungsstellung nach Bestätigung des Angebots (dies wird derzeit separat gehandhabt [5]).
*   Komplexe Verhandlungen oder maßgeschneiderte Angebote, die stark von den vordefinierten Paketen abweichen.
*   Handling von Absagen oder Änderungen weniger als 4 Tage vor der Veranstaltung [8, 15].
*   Automatische Nachverfolgung unbestätigter Angebote.

## 🤝 Key Stakeholders

*   Jasmin Catering Management (Salma Armachi [1, 10, 17], Fadi Zaim [3, 16])
*   Kunden von Jasmin Catering
*   Entwicklungsteam

## 🛠️ Benötigte Technologie & Tools

*   **KI-Modell:** Claude AI API Key (wie vom Kunden angegeben).
*   **Plattform für KI-Agenten/Workflow-Automatisierung:** Azure AI Foundry [5] oder n8n.
*   **Datenbank/Wissensbasis:** Zur Speicherung von strukturierten Daten (Menüdetails [10-14], Preise, Paketregeln, AGBs [5, 6, 15], etc.).
*   **E-Mail-Service:** Für den zuverlässigen Versand von E-Mails (z.B. SendGrid, oder ein dedizierter SMTP-Service).
*   **Anfrageerfassung:** Integration mit Google Forms [3] oder dem bestehenden/erweiterten Website-Formular [4].

## 🇩🇪 Inhaltlicher Fokus (Deutsch)

Es ist wichtig zu betonen, dass, obwohl die *Beschreibung* und *technische Planung* des Projekts in dieser Dokumentation auf Englisch erfolgen, die *Interaktion* des KI-Agenten mit den Kunden und der *Inhalt* der generierten Angebote und E-Mails **auf Deutsch** sein werden [6-9]. Die Menüdetails und Beschreibungen in den Quellen sind ebenfalls auf Deutsch [10-14]. Der Claude AI Agent muss in der Lage sein, deutsche Anfragen zu verstehen und flüssig auf Deutsch zu antworten und Texte zu generieren.

## 🤖 Technische Implementierungspläne

Hier werden zwei mögliche Pläne für die technische Umsetzung der KI-Agenten-Lösung vorgestellt:

### 1️⃣ Plan 1: Umsetzung mit Azure AI Foundry (Schwerpunkt Agent Service & RAG)

*   **Plattform:** Microsoft Azure, Nutzung der Azure AI Foundry Dienste [5].
*   **Konzept:** Aufbau einer intelligenten Lösung auf Basis der Azure Cloud. Der Fokus liegt auf der Nutzung des Azure AI Agent Service in Kombination mit RAG, um Wissen aus einer Wissensbasis abzurufen und nutzbar zu machen.
*   **Implementierungsschritte:**
    1.  **Anfrageerfassung (Ingestion):** Konfiguration eines Eingangs-Triggers. Dies könnte eine Azure Function oder eine Logic App sein, die auf eine neue Formularübermittlung (z.B. via Google Forms Integration oder Webhook vom Website-Formular) reagiert [3, 4].
    2.  **Datenspeicherung & Wissensbasis (Knowledge Base):** Einrichten einer Wissensbasis. Dies kann eine Kombination aus Azure Blob Storage für Dokumente (wie AGBs [5, 15], Referenzen [5]) und einer Datenbank wie Azure SQL Database oder Cosmos DB für strukturierte Daten (Menüpunkte [10-14], Preise, Paketdefinitionen) sein. Diese Daten werden für RAG aufbereitet, möglicherweise unter Nutzung von Azure AI Search (Indexing).
    3.  **Azure AI Agent Service:** Konfiguration und Deployment des Hauptagenten auf Azure AI Foundry. Dieser Agent wird der Orchestrator. Er nimmt die Anfrageinformationen von der Ingestion-Schicht entgegen.
    4.  **Integration Claude AI:** Der Azure AI Agent wird so konfiguriert, dass er die Claude AI API als zugrundeliegendes großes Sprachmodell (LLM) nutzt. Claude wird verwendet, um komplexe Anfragen zu verstehen, Freitext zu verarbeiten und Formulierungsvorschläge zu liefern.
    5.  **Angebotslogik (Offer Generation Logic):** Implementierung der Logik, die basierend auf den extrahierten Anfragedaten und durch Abfrage der Wissensbasis (via RAG über Azure AI Search) die relevanten Menüpunkte, Mengen und Preise zusammenstellt, um die drei Angebotsvarianten zu kalkulieren und zu strukturieren [3, 6]. Diese Logik kann direkt im Agenten oder in begleitenden Azure Functions/Logic Apps implementiert werden.
    6.  **E-Mail-Generierung & Versand:** Der generierte Angebotstext und die Details werden in die E-Mail-Vorlage formatiert [6-9]. Ein E-Mail-Dienst (z.B. über Azure Communication Services oder SendGrid via Azure Marketplace) wird aufgerufen, um die E-Mail an den Kunden zu versenden.
    7.  **Deployment & Monitoring:** Bereitstellung der Dienste in Azure und Einrichtung von Monitoring und Logging zur Überwachung der Agentenaktivität und Fehlersuche.

### 2️⃣ Plan 2: Umsetzung mit n8n (Workflow Automatisierung)

*   **Plattform:** n8n (Open Source Workflow Automation Tool, kann selbst gehostet oder als Cloud-Dienst genutzt werden).
*   **Konzept:** Aufbau eines automatisierten Workflows in n8n, der verschiedene Dienste über APIs miteinander verbindet.
*   **Implementierungsschritte:**
    1.  **Anfrageerfassung (Webhook/Node):** Konfiguration eines n8n Webhook Nodes oder eines spezifischen Nodes (z.B. Google Forms Node), um eingehende Anfragen zu erfassen [3, 4].
    2.  **Datenverarbeitung im Workflow:** Nutzung verschiedener n8n Nodes (z.B. Function Nodes, JSON Nodes) zur Extraktion, Bereinigung und Strukturierung der Daten aus dem Formularinput.
    3.  **Datenhaltung (externe DB/Sheet):** Speicherung von Menüdetails [10-14], Paketstrukturen, Preisregeln, AGBs [5, 15] etc. in einer externen Datenbank (z.B. PostgreSQL, MySQL) oder einem Cloud-Sheet (Google Sheets, Airtable), auf die n8n per entsprechendem Node zugreifen kann.
    4.  **Claude AI Integration:** Verwendung eines HTTP Request Nodes, um die Claude AI API aufzurufen. Der Workflow kann Claude nutzen, um Freitext-Wünsche zu interpretieren oder formulierte Textbausteine für das Angebot zu erstellen. Die Kernlogik zur Auswahl der Menüpunkte und Kalkulation basiert jedoch primär auf der Logik des n8n Workflows, der auf die externe Wissensbasis zugreift.
    5.  **Angebotslogik im Workflow:** Aufbau der Logik innerhalb des n8n Workflows mit Nodes wie IF/ELSE, Function Nodes, Set Nodes etc., um die Anfragedaten mit den Informationen aus der externen Datenquelle zu kombinieren und die drei Angebote zu kalkulieren und zu strukturieren [3, 6].
    6.  **E-Mail-Generierung & Versand:** Formatierung des generierten Angebotstextes und der Details in eine E-Mail-Struktur innerhalb des Workflows. Nutzung eines n8n E-Mail Nodes (z.B. SMTP, SendGrid Node) zum Versenden der E-Mail im Format der Vorlage [6-9].
    7.  **Deployment & Monitoring:** Bereitstellung des n8n Workflows (Self-hosted oder Cloud) und Nutzung der n8n internen Monitoring-Funktionen.

### 3️⃣ Plan 3: Hybrider Ansatz (Optional / Starthilfe)

*   **Konzept:** Beginn mit einer einfacheren Automatisierung, die nur Teile des Prozesses abdeckt.
*   **Implementierungsschritte:** Fokussierung auf die automatische Extraktion der Hauptanfragedaten (Gästezahl, Datum, Ort) und Nutzung der Claude AI API, um einen *Rohentwurf* eines Angebots zu generieren, der auf einer simpleren Vorlage und den extrahierten Hauptdaten basiert. Dieser Rohentwurf wird dann an das Jasmin Catering Team zur *manuellen Überprüfung, Anpassung und Fertigstellung* gesendet, bevor er an den Kunden geht. Dies reduziert das Automatisierungsziel, minimiert aber die Komplexität der Logik für die "3 Angebote / Packages" und erlaubt einen schnelleren Start. Dies könnte ein erster Schritt sein, bevor zu Plan 1 oder 2 übergegangen wird.

## ⚠️ Wichtige Hinweise

*   Die **detaillierte Struktur der "3 Angebote / Packages" und die zugehörigen Preiskalkulationsregeln** sind für die automatisierte Angebotserstellung essentiell, aber in den bereitgestellten Quellen nicht vollständig dokumentiert. Dies ist eine kritische Anforderung, die zu Beginn des Projekts genau definiert werden muss. [3, 5, 6]
*   Die Integration mit dem **bestehenden Website-Formular** hängt von dessen technischer Beschaffenheit ab. Ein Google Form [3] bietet in der Regel einfachere und standardisierte Integrationsschnittstellen.
*   Informationen über die Fähigkeiten und die Einrichtung von **Azure AI Foundry** und **n8n** sowie allgemeine Konzepte von AI-Agenten, RAG und Workflow-Automatisierung wurden meinem allgemeinen Wissen entnommen und sind nicht direkt in den bereitgestellten Quellen enthalten.

---

Ich hoffe, dieser Markdown-Plan bietet eine klare Struktur für das Projekt. Bitte lassen Sie mich wissen, wenn Sie weitere Details benötigen oder spezifische Aspekte klären möchten!