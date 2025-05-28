ENGLISH:

# ✨ Project: Jasmin Catering AI Agent Solution ✨ [1]

## 📝 Project Description [1]

This project aims to automate and optimize the process of handling customer inquiries and creating offers for Jasmin Catering. Jasmin Catering is a family-run business in Berlin offering full-service catering for events with 15 to 500 guests, specializing in Syrian fusion cuisine [1, 18]. Currently, inquiries are captured via a form (website or Google Form) [1, 19]. Based on the collected information (such as date, location, number of people, food preferences, budget, etc. [1, 20]), the caterer or potentially an agent creates and sends three different offers/packages via email [1, 20, 21]. The proposed solution will utilize an AI agent to increase the efficiency and scalability of this inquiry and offer process [1]. The agent should be capable of automatically generating offer suggestions from the inquiry information [1] and supporting communication with the customer.

## 🎯 Goals [2]

*   **Accelerate Offer Creation:** Reducing the processing time from inquiry to dispatch of the offer. Currently, an offer is aimed to be sent within 72 hours [2, 19].
*   **Automate Routine Tasks:** Automatic extraction of relevant information from customer inquiries [2, 20] and generation of structured offer suggestions [2, 20, 21].
*   **Improve Efficiency:** Enabling the processing of a larger number of inquiries without a proportional increase in manual effort [2].
*   **Integration:** Seamless connection to existing or expandable inquiry forms (website form, Google Form) [3, 19].
*   **Consistency:** Ensuring that offers and communication adhere to defined standards and templates [3, 21].

## 🏗️ Scope [3]

**In-Scope:** [3]

*   Capturing inquiry data from a provided form (Google Form or website form) [3, 19].
*   Extraction and processing of key information from the inquiry (date, number of guests, location, food/drink preferences, dietary preferences like vegetarian/vegan, budget, etc.) [3, 20].
*   Accessing a knowledge base with menu details, package structures, pricing information, and terms and conditions [4, 20-24].
*   Generation of drafts for three different offer variants ("3 Angebote / Packages") based on inquiry details and defined logic [4, 20, 21].
*   Formatting the generated offers into an email that matches the template [4, 21].
*   Sending the offer email to the customer [4].
*   Integration with the Claude AI API as the chat model for natural language processing [4].

**Out-of-Scope (initial):** [5]

*   Full conversation with the customer throughout the entire booking process (e.g., clarifying details, changes after sending the offer, payment processing). The agent initially focuses on the first step: Inquiry -> Offer [5].
*   Automatic invoicing after offer confirmation (this is currently handled separately [5, 25]).
*   Complex negotiations or customized offers that significantly deviate from the predefined packages [5].
*   Handling cancellations or changes less than 4 days before the event [5, 23].
*   Automatic follow-up on unconfirmed offers [6].

## 🤝 Key Stakeholders [6]

*   Jasmin Catering Management (Salma Armachi [6, 26, 27], Fadi Zaim [6, 20])
*   Customers of Jasmin Catering [6]
*   Development Team [6]

## 🛠️ Required Technology & Tools [6]

*   **AI Model:** Claude AI API Key (as specified by the customer) [6].
*   **Platform for AI Agents/Workflow Automation:** Azure AI Foundry [6, 25] or n8n.
*   **Database/Knowledge Base:** For storing structured data (menu details [6, 21-23], prices, package rules, T&Cs [7, 20, 23], etc.).
*   **Email Service:** For reliable sending of emails (e.g., SendGrid, or a dedicated SMTP service) [7].
*   **Inquiry Capture:** Integration with Google Forms [7, 20] or the existing/expanded website form [7, 19].

## 🇩🇪 Content Focus (German) [7]

It is important to emphasize that, although the *description* and *technical planning* of the project in this documentation are in English, the AI agent's *interaction* with customers and the *content* of the generated offers and emails **will be in German** [7, 21]. The menu details and descriptions in the sources are also in German [7, 21-23]. The Claude AI Agent must be able to understand German inquiries and respond and generate text fluently in German.

## 🤖 Technical Implementation Plans [8]

Here are two possible plans for the technical implementation of the AI Agent solution: [8]

### 1️⃣ Plan 1: Implementation with Azure AI Foundry (Focus on Agent Service & RAG) [8]

*   **Platform:** Microsoft Azure, utilizing Azure AI Foundry services [8, 25].
*   **Concept:** Building an intelligent solution based on the Azure Cloud. The focus is on using the Azure AI Agent Service in combination with RAG to retrieve and utilize knowledge from a knowledge base [8].
*   **Implementation Steps:** [9]
    1.  **Inquiry Capture (Ingestion):** Configuration of an input trigger. This could be an Azure Function or Logic App that reacts to a new form submission (e.g., via Google Forms integration or webhook from the website form) [9, 19].
    2.  **Data Storage & Knowledge Base:** Setting up a knowledge base. This can be a combination of Azure Blob Storage for documents (like T&Cs [9, 23], references [9]) and a database like Azure SQL Database or Cosmos DB for structured data (menu items [9, 21-23], prices, package definitions). This data is prepared for RAG, possibly using Azure AI Search (Indexing).
    3.  **Azure AI Agent Service:** Configuration and deployment of the main agent on Azure AI Foundry. This agent will be the orchestrator. It receives the inquiry information from the ingestion layer [10].
    4.  **Integration Claude AI:** The Azure AI Agent is configured to use the Claude AI API as the underlying large language model (LLM). Claude is used to understand complex inquiries, process free text, and provide wording suggestions [10].
    5.  **Offer Logic (Offer Generation Logic):** Implementation of the logic that, based on the extracted inquiry data and by querying the knowledge base (via RAG over Azure AI Search), compiles the relevant menu items, quantities, and prices to calculate and structure the three offer variants [10, 20, 21]. This logic can be implemented directly within the agent or in accompanying Azure Functions/Logic Apps.
    6.  **Email Generation & Sending:** The generated offer text and details are formatted into the email template [11, 21]. An email service (e.g., via Azure Communication Services or SendGrid via Azure Marketplace) is called to send the email to the customer [11].
    7.  **Deployment & Monitoring:** Deployment of services in Azure and setup of monitoring and logging to track agent activity and troubleshoot errors [11].

### 2️⃣ Plan 2: Implementation with n8n (Workflow Automation) [12]

*   **Platform:** n8n (Open Source Workflow Automation Tool, can be self-hosted or used as a cloud service) [12].
*   **Concept:** Building an automated workflow in n8n that connects various services via APIs [12].
*   **Implementation Steps:** [12]
    1.  **Inquiry Capture (Webhook/Node):** Configuration of an n8n Webhook Node or a specific Node (e.g., Google Forms Node) to capture incoming inquiries [12, 19].
    2.  **Data Processing within the Workflow:** Use of various n8n Nodes (e.g., Function Nodes, JSON Nodes) to extract, clean, and structure the data from the form input [13].
    3.  **Data Storage (external DB/Sheet):** Storage of menu details [13, 21-23], package structures, pricing rules, T&Cs [13, 23], etc., in an external database (e.g., PostgreSQL, MySQL) or a cloud sheet (Google Sheets, Airtable) that n8n can access via an appropriate Node.
    4.  **Claude AI Integration:** Using an HTTP Request Node to call the Claude AI API. The workflow can use Claude to interpret free-text wishes or generate formulated text blocks for the offer. However, the core logic for selecting menu items and calculation is primarily based on the logic of the n8n workflow accessing the external knowledge base [13].
    5.  **Offer Logic within the Workflow:** Building the logic within the n8n workflow using Nodes like IF/ELSE, Function Nodes, Set Nodes, etc., to combine the inquiry data with information from the external data source and calculate and structure the three offers [14, 20, 21].
    6.  **Email Generation & Sending:** Formatting the generated offer text and details into an email structure within the workflow. Using an n8n email Node (e.g., SMTP, SendGrid Node) to send the email in the template format [14, 21].
    7.  **Deployment & Monitoring:** Deployment of the n8n workflow (self-hosted or cloud) and use of n8n's internal monitoring functions [15].

### 3️⃣ Plan 3: Hybrid Approach (Optional / Quick Start) [15]

*   **Concept:** Starting with a simpler automation that covers only parts of the process [15].
*   **Implementation Steps:** Focusing on automatically extracting the main inquiry data (number of guests, date, location) and using the Claude AI API to generate a *raw draft* of an offer based on a simpler template and the extracted main data [15]. This raw draft is then sent to the Jasmin Catering team for *manual review, adjustment, and finalization* before going to the customer [15]. This reduces the automation goal but minimizes the complexity of the logic for the "3 Angebote / Packages" and allows for a quicker start [15]. This could be a first step before moving to Plan 1 or 2 [15].

## ⚠️ Important Notes [16]

*   The **detailed structure of the "3 Angebote / Packages" and the associated price calculation rules** are essential for automated offer creation but are not fully documented in the provided sources [16, 20, 21]. This is a critical requirement that must be precisely defined at the beginning of the project.
*   Integration with the **existing website form** depends on its technical nature [16]. A Google Form [16, 20] generally offers simpler and standardized integration interfaces.
*   Information about the capabilities and setup of **Azure AI Foundry** and **n8n**, as well as general concepts of AI agents, RAG, and workflow automation, was drawn from my general knowledge and is **not directly contained in the provided sources** [17].

---

DEUTSCH:

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
