# 🍽️ Jasmin Catering AI Agent

## 🚀 **Current Status: LogicApp Email-to-Slack Integration Ready**

Automated catering inquiry processing system for Jasmin Catering - a Syrian fusion restaurant in Berlin specializing in events with 15-500 guests.

### ✅ **What's Working Now:**
- **Email Monitoring**: Automatic Gmail monitoring for `mabu.mate@gmail.com`
- **Slack Integration**: Real-time notifications to `#gmail-inbox` in `mabured.slack.com`
- **Structured Workflow**: Complete LogicApp workflow for email processing
- **Azure Deployment**: Ready-to-deploy scripts with proper authentication
- **Version Control**: GitHub integration with automatic backups

---

## 📁 **Project Structure**

```
/Users/ma3u/projects/jasmin-catering-ai-agent/
├── README.md                          # This documentation
├── azure.yaml                         # Azure Developer CLI configuration
├── .gitignore                         # Git ignore rules
├── LAST_UPDATED                       # Last backup timestamp
├── config/
│   └── azure-resources.json           # Azure resource configuration
├── logicapp/
│   ├── workflow-definition.json       # Complete LogicApp workflow
│   └── workflow-parameters.json       # Generated during deployment
├── scripts/
│   ├── deploy-logicapp.sh             # Main deployment script ⚙️
│   └── backup-to-github.sh            # GitHub backup automation 💾
└── docs/
    └── deployment-guide.md            # Detailed setup instructions
```

---

## 🚀 **Quick Start Guide**

### **1. Deploy the LogicApp** 
```bash
cd /Users/ma3u/projects/jasmin-catering-ai-agent
./scripts/deploy-logicapp.sh
```

### **2. Authorize OAuth Connections**
After deployment, the script provides direct Azure Portal links:
- **Gmail Connection**: Authorize with `mabu.mate@gmail.com`
- **Slack Connection**: Authorize with `mabured.slack.com` workspace

### **3. Test the Integration**
```bash
# Send test email to mabu.mate@gmail.com
# Check #gmail-inbox channel in Slack workspace
# Expected: Formatted message with email details
```

### **4. Backup Configuration**
```bash
./scripts/backup-to-github.sh
```

---

## 📧 **Email Processing Workflow**

```mermaid
graph TD
    A[📧 Email arrives at mabu.mate@gmail.com] --> B[🔄 LogicApp Triggered]
    B --> C[📋 Parse Email Content]
    C --> D[💬 Format Slack Message]
    D --> E[📤 Post to #gmail-inbox]
    E --> F[🤖 Ready for AI Processing]
```

### **Slack Message Format:**
```
📧 New Email for Jasmin Catering
From: customer@example.com
Subject: Wedding catering inquiry for 150 guests
Received: 2025-06-20T14:30:00Z
Email ID: abc123...

Preview: Hello, we need catering for 150 guests on March 15th...

🤖 Next Steps: This email will be processed by the Jasmin Catering AI Agent
```

---

## 🏗️ **Architecture Overview**

### **Current Implementation:**
- **Azure LogicApps**: Email processing and Slack notifications
- **Gmail API**: Email monitoring (`mabu.mate@gmail.com`)
- **Slack API**: Team notifications (`mabured.slack.com`)
- **GitHub**: Version control and automated backups

### **Next Phase - AI Integration:**
- **Azure AI Foundry**: Natural language processing and offer generation
- **RAG System**: Menu knowledge base and pricing logic
- **German Templates**: Professional customer communication
- **Automated Responses**: 3 customized catering packages per inquiry

---

## 🔧 **Configuration Details**

### **Azure Resources:**
- **Subscription**: `b58b1820-35f0-4271-99be-7c84d4dd40f3`
- **Resource Group**: `logicapp-jasmin-catering_group`
- **LogicApp**: `mabu-logicapps`
- **Location**: `West Europe`

### **Email & Communication:**
- **Gmail**: `mabu.mate@gmail.com` (monitored)
- **Slack Workspace**: `mabured.slack.com`
- **Slack Channel**: `#gmail-inbox`
- **Future Email**: `info@jasmincatering.com` (production)

### **AI Foundry Project:**
```
https://ai.azure.com/foundryProject/overview?wsid=/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/rg-damyandesign-1172/providers/Microsoft.CognitiveServices/accounts/jasmin-catering-resource/projects/jasmin-catering&tid=6aa73eee-cf67-47a8-8231-d97cdb4b21a0
```

---

## 🍽️ **Business Logic - Syrian Fusion Catering**

### **Target Events:**
- Corporate meetings and conferences
- Wedding celebrations  
- Private parties and gatherings
- Business lunch catering
- Cultural events and festivals

### **Menu Specialties:**
- **Humus with Love** - Signature recipe variations
- **Mutabal** - Smoked eggplant specialties
- **Falafel Cups** - Traditional with modern presentation
- **Vegan Kufta** - Mixed vegetable specialties  
- **Malakieh Desserts** - "The Queen" pistachio treats
- **Spinat & Oliven Burak** - Vegan pastry options

### **Service Capabilities:**
- **Guest Count**: 15-500 people
- **Event Types**: Finger food, warm meals, full service
- **Dietary Options**: Vegetarian, vegan, traditional meat
- **Service Areas**: Berlin and surrounding regions
- **Equipment**: Professional setup, service personnel

---

## 🛠️ **Development Commands**

### **Azure CLI Deployment:**
```bash
# Deploy with Azure CLI
./scripts/deploy-logicapp.sh

# Alternative: Azure Developer CLI
azd up
```

### **GitHub Operations:**
```bash
# Manual backup to GitHub
./scripts/backup-to-github.sh

# Check current status
git status
git log --oneline
```

### **Azure Management:**
```bash
# Check LogicApp status
az logicapp show --resource-group logicapp-jasmin-catering_group --name mabu-logicapps

# View run history
az logicapp run list --resource-group logicapp-jasmin-catering_group --name mabu-logicapps
```

---

## 🔮 **Roadmap & Next Steps**

### **Phase 1: ✅ Email Integration (Current)**
- [x] Gmail to Slack forwarding
- [x] LogicApp workflow deployment
- [x] OAuth authentication setup
- [x] GitHub version control

### **Phase 2: 🔄 AI Agent Development**
- [ ] Azure AI Foundry agent integration
- [ ] RAG system for menu knowledge base
- [ ] German language template system
- [ ] Automated inquiry parsing

### **Phase 3: 🔄 Automated Offer Generation**
- [ ] 3-package offer generation logic
- [ ] Dynamic pricing calculations
- [ ] Professional German email templates
- [ ] Customer response automation

### **Phase 4: 🔄 Production Deployment**
- [ ] Migration to `info@jasmincatering.com`
- [ ] Customer feedback integration
- [ ] Analytics and reporting
- [ ] Scale testing for high volume

---

## 🧪 **Testing & Validation**

### **Current Testing:**
```bash
# Test email trigger
echo "Send email to: mabu.mate@gmail.com"
echo "Check Slack: mabured.slack.com #gmail-inbox"
echo "Verify formatted message appears"
```

### **AI Agent Testing Example:**
**Sample Customer Inquiry:**
> "Hello, I need catering for an anniversary celebration in central Berlin on June 29, 2025. There will be 30 people, we need 4 meals with 30-45 minute pauses and drinks including wine."

**Expected AI Response:** Professional German offer with 3 package options including Syrian fusion specialties, pricing, and service details.

---

## 🎯 **Success Metrics**

- **Response Time**: From inquiry to offer generation < 30 minutes
- **Accuracy**: 95%+ correct information extraction from emails
- **Customer Satisfaction**: Professional German communication standards
- **Efficiency**: 3 tailored packages per inquiry automatically generated
- **Scalability**: Handle 50+ inquiries per day without manual intervention

---

## 📞 **Support & Contact**

- **GitHub Repository**: [ma3u/jasmin-catering-ai-agent](https://github.com/ma3u/jasmin-catering-ai-agent)
- **Azure Portal**: [LogicApp Dashboard](https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/logicapp-jasmin-catering_group/providers/Microsoft.Logic/workflows/mabu-logicapps)
- **Slack Workspace**: `mabured.slack.com #gmail-inbox`

---

**🇸🇾 Serving Berlin with authentic Syrian fusion cuisine since 2020! ✨**