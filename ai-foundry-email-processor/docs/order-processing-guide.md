# Jasmin Catering Order Processing Guide

## Overview

The Jasmin Catering Order Processing System automates the handling of catering inquiries received via email. It uses Azure AI Foundry to analyze emails, generate response drafts, and facilitates human approval before sending responses.

## How It Works

### 1. Email Reception
- System monitors `matthias.buchhorn@web.de` inbox
- Triggers on emails containing keywords: "order", "bestell", "anfrage", "catering", "event"
- Checks every 5 minutes for new emails

### 2. AI Analysis
The AI agent analyzes each email to extract:
- **Language**: German or English
- **Event Details**: Date, guest count, location
- **Requirements**: Menu preferences, dietary restrictions
- **Budget**: Stated or implied budget range
- **Priority**: Urgent vs. normal requests

### 3. Response Generation
Based on the analysis, the AI generates:
- Professional response draft in the same language
- Appropriate catering package suggestion
- Price estimate based on guest count
- List of any missing information needed

### 4. Approval Workflow
- Draft is stored in Azure Storage
- Notification sent to Teams channel
- Team can:
  - ✅ Approve and send immediately
  - ✏️ Edit the draft before sending
  - ❌ Reject (no response sent)

### 5. Email Delivery
Once approved, the system:
- Sends the response via SMTP
- Logs the transaction
- Archives the original email and response

## Response Templates

### Standard Packages

1. **Basic Package** (25€/person)
   - Simple mezze selection
   - 2 main dishes
   - Basic dessert

2. **Standard Package** (35-45€/person)
   - Full mezze spread
   - 3 main dishes
   - Mixed desserts
   - Service staff included

3. **Premium Package** (45-60€/person)
   - Extended mezze variety
   - 4 main dishes
   - Premium desserts
   - Full service and equipment

4. **Luxury Package** (60€+/person)
   - Complete Syrian feast
   - Live cooking stations
   - Premium service
   - Custom menu options

## Handling Different Inquiry Types

### 1. Complete Inquiries
**Contains**: Date, guest count, location, requirements
**Action**: Generate detailed quote with specific menu

### 2. Incomplete Inquiries
**Missing**: Key information like date or guest count
**Action**: Friendly response requesting missing details

### 3. Urgent Requests
**Timeline**: Event within 7 days
**Action**: Express service acknowledgment, quick turnaround

### 4. Large Events
**Size**: 100+ guests
**Action**: Comprehensive proposal with multiple options

### 5. Special Dietary Requirements
**Needs**: Vegan, gluten-free, allergies
**Action**: Customized menu with clear labeling

## Best Practices

### Response Timing
- **Normal inquiries**: Respond within 24 hours
- **Urgent requests**: Respond within 4 hours
- **Weekend inquiries**: Monday morning response

### Language Guidelines
- Match the customer's language (German/English)
- Use formal tone initially (Sie in German)
- Professional but warm communication style

### Pricing Transparency
- Always include VAT in quotes
- Clarify what's included (service, equipment)
- Mention additional costs upfront

### Follow-up Protocol
1. Initial response with quote
2. Follow-up after 3 days if no reply
3. Final follow-up after 1 week
4. Archive after 2 weeks of no response

## Common Scenarios

### Wedding Inquiries
- Emphasize experience with celebrations
- Suggest tasting session
- Highlight special wedding packages
- Mention Malakieh wedding dessert

### Corporate Events
- Focus on professional service
- Highlight timely delivery
- Offer invoice payment options
- Suggest popular business packages

### Private Parties
- Warm, personal tone
- Flexible menu options
- Budget-conscious suggestions
- Family-style service options

### Cultural Events
- Show understanding of traditions
- Offer authentic Syrian options
- Accommodate religious requirements
- Suggest traditional presentations

## Quality Standards

### Every Response Must Include:
- [ ] Greeting with customer name
- [ ] Acknowledgment of their request
- [ ] Clear menu/package proposal
- [ ] Total price with VAT
- [ ] Next steps
- [ ] Contact information
- [ ] Professional closing

### Never Include:
- ❌ Prices without VAT
- ❌ Vague timeline promises
- ❌ Unconfirmed availability
- ❌ Personal opinions
- ❌ Competitor comparisons

## Escalation Procedures

### When to Escalate:
- Budget exceeds 10,000€
- Guest count over 300
- Special location requirements
- VIP or celebrity events
- Diplomatic functions

### Escalation Process:
1. Flag in Teams notification
2. Add "ESCALATION" tag
3. Include reason for escalation
4. Wait for senior approval
5. May require custom pricing

## Metrics and KPIs

Track these metrics monthly:
- Response time average
- Approval vs. rejection rate
- Conversion rate (quotes to bookings)
- Customer satisfaction scores
- AI accuracy in understanding requests

## Continuous Improvement

### Weekly Reviews:
- Analyze rejected drafts
- Identify AI misunderstandings
- Update knowledge base
- Refine response templates

### Monthly Updates:
- Review pricing accuracy
- Update seasonal menus
- Adjust package offerings
- Enhance AI instructions