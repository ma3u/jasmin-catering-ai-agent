# 📧 Email Test Scenarios for Jasmin Catering AI Agent

## 🧪 Test Email Templates

Send these test emails to **mabu.mate@gmail.com** to verify your Azure Functions integration.

### **Test 1: Basic Catering Inquiry (German)**
```
Subject: Catering Anfrage für Firmenevent

Hallo,

wir planen ein Firmenevent am 25. Juli 2025 und benötigen Catering für 45 Personen. 
Das Event findet in Berlin-Mitte statt.

Können Sie uns ein Angebot erstellen?

Mit freundlichen Grüßen,
Test Kunde
test@example.com
```

**Expected Result:** 
- ✅ Detected as catering inquiry
- ✅ Guest count: 45 people  
- ✅ Event date: 25. Juli 2025
- ✅ Slack notification in #gmail-inbox

---

### **Test 2: Wedding Catering (English)**
```
Subject: Wedding catering for 120 guests

Hello,

We need catering services for our wedding on March 15th, 2025.
We expect around 120 guests and the venue is in Berlin.

Could you please send us your packages and pricing?

Best regards,
Wedding Couple
wedding@example.com
```

**Expected Result:**
- ✅ Detected as catering inquiry
- ✅ Guest count: 120 people
- ✅ Event date: March 15th, 2025
- ✅ Slack notification with rich formatting

---

### **Test 3: Non-Catering Email (Should be filtered out)**
```
Subject: General restaurant question

Hello,

What are your opening hours for the restaurant?
Do you accept reservations for dinner?

Thanks,
Regular Customer
diner@example.com
```

**Expected Result:**
- ❌ NOT detected as catering inquiry
- ❌ NO Slack notification
- ✅ Email marked as read but ignored

---

### **Test 4: Large Event (Stress test)**
```
Subject: Catering für Konferenz - 350 Teilnehmer

Guten Tag,

wir organisieren eine große Konferenz am 10. September 2025 
mit 350 Teilnehmern im CityCube Berlin.

Benötigt wird:
- Frühstück für 350 Personen
- Mittagsbuffet  
- 2 Kaffeepausen
- Vegetarische und vegane Optionen

Bitte senden Sie uns Ihr Angebot.

Freundliche Grüße,
Event Manager
events@conference.de
```

**Expected Result:**
- ✅ Detected as catering inquiry
- ✅ Guest count: 350 people
- ✅ Event date: 10. September 2025
- ✅ Rich Slack notification with all details
- ✅ Keywords detected: konferenz, teilnehmer, buffet

---

## 🔍 **How to Monitor Test Results**

### **1. Check Slack Channel**
Go to your **mabured.slack.com** workspace → **#gmail-inbox** channel

**Expected Messages:**
```
📧 New Catering Inquiry for Jasmin Catering

From: test@example.com
Subject: Catering Anfrage für Firmenevent

Guest Count: 45 people
Event Date: 25. Juli 2025
Received: 2025-06-23T10:30:00Z

Preview: Hallo, wir planen ein Firmenevent am 25. Juli 2025...

🤖 This email will be processed by the Jasmin Catering AI Agent

[📧 View in Gmail] [🤖 Process with AI]
```

### **2. Check Azure Functions Logs**
```bash
# View live logs from Azure Functions
az functionapp logstream jasmin-gmail-functions --resource-group jasmin-functions-rg

# Or check in Azure Portal
https://portal.azure.com > jasmin-gmail-functions > Functions > Monitor
```

### **3. Check Gmail Processing**
- Emails should be marked as **read** after processing
- Check in **mabu.mate@gmail.com** inbox

---

## 🛠️ **Testing Commands**

### **Run Local Slack Test**
```bash
cd azure-functions
export SLACK_TOKEN=xoxb-your-bot-token
node test-slack-integration.js
```

### **Run Azure Integration Test**
```bash
cd azure-functions
export SLACK_TOKEN=xoxb-your-bot-token
./test-azure-integration.sh
```

### **Manual Function Trigger**
```bash
# Test Gmail connection
curl https://jasmin-gmail-functions.azurewebsites.net/api/testGmailConnection

# Get OAuth URL for setup
curl https://jasmin-gmail-functions.azurewebsites.net/api/getAuthUrl
```

---

## 🚨 **Troubleshooting Test Issues**

### **No Slack Notifications**
1. ✅ **Check bot token:** `SLACK_TOKEN` starts with `xoxb-`
2. ✅ **Check bot permissions:** `chat:write`, `chat:write.public`
3. ✅ **Add bot to channel:** `/invite @YasminCatering` in #gmail-inbox
4. ✅ **Check function logs:** Look for error messages

### **Wrong Guest Count/Date Extraction**
1. ✅ **Check regex patterns** in `EmailParser.extractGuestCount()`
2. ✅ **Test with different formats:** "50 Personen", "für 30 Gäste", etc.
3. ✅ **Check date formats:** DD.MM.YYYY, MM/DD/YYYY, YYYY-MM-DD

### **All Emails Being Ignored**
1. ✅ **Check keyword detection** in `EmailParser.isCateringInquiry()`
2. ✅ **Verify Gmail API connection** 
3. ✅ **Check timer function** is running every 5 minutes

### **Gmail Authentication Issues**
1. ✅ **Refresh OAuth token:** Use OAuth Playground to get new token
2. ✅ **Check API quotas:** Google Cloud Console → Gmail API
3. ✅ **Verify credentials:** Client ID, Client Secret, Refresh Token

---

## 📊 **Expected Performance Metrics**

| Metric | Expected Value | How to Check |
|--------|----------------|--------------|
| **Response Time** | < 30 seconds | Send email → Check Slack |
| **Detection Accuracy** | 95%+ for catering keywords | Test with various email types |
| **Slack Message Format** | Rich blocks with buttons | Visual check in #gmail-inbox |
| **Guest Count Extraction** | Numbers + "Personen/Gäste" | Test with different formats |
| **Date Extraction** | DD.MM.YYYY format | German date formats priority |

---

## 🎯 **Success Criteria**

### ✅ **All Tests Pass When:**
1. **Catering emails** → Slack notifications within 5 minutes
2. **Non-catering emails** → No Slack notifications
3. **Guest counts** extracted correctly (45, 120, 350)
4. **Event dates** parsed in German format
5. **Rich formatting** appears in Slack with action buttons
6. **Error handling** graceful (no crashes on malformed emails)

### 🚀 **Ready for Production When:**
- ✅ All 4 test emails processed correctly
- ✅ No false positives (non-catering emails ignored)
- ✅ Slack formatting looks professional
- ✅ Gmail OAuth working without manual intervention
- ✅ Azure Functions logs show no errors

---

**🇸🇾 Now test your Syrian fusion catering AI agent! ✨**
