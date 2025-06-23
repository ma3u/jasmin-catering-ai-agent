/**
 * Parse Gmail message into structured format
 */
class EmailParser {
  /**
   * Extract email headers
   */
  static extractHeaders(headers) {
    const result = {};
    headers.forEach(header => {
      result[header.name.toLowerCase()] = header.value;
    });
    return result;
  }

  /**
   * Decode base64 email body
   */
  static decodeBody(body) {
    if (!body || !body.data) return '';
    
    // Gmail API returns base64url encoded data
    const base64 = body.data.replace(/-/g, '+').replace(/_/g, '/');
    return Buffer.from(base64, 'base64').toString('utf-8');
  }

  /**
   * Extract email body from message parts
   */
  static extractBody(payload) {
    let textBody = '';
    let htmlBody = '';

    const extractFromParts = (parts) => {
      parts.forEach(part => {
        if (part.mimeType === 'text/plain' && part.body.data) {
          textBody = this.decodeBody(part.body);
        } else if (part.mimeType === 'text/html' && part.body.data) {
          htmlBody = this.decodeBody(part.body);
        } else if (part.parts) {
          extractFromParts(part.parts);
        }
      });
    };

    if (payload.parts) {
      extractFromParts(payload.parts);
    } else if (payload.body) {
      if (payload.mimeType === 'text/plain') {
        textBody = this.decodeBody(payload.body);
      } else if (payload.mimeType === 'text/html') {
        htmlBody = this.decodeBody(payload.body);
      }
    }

    return {
      text: textBody,
      html: htmlBody
    };
  }

  /**
   * Parse Gmail message into structured format
   */
  static parseMessage(message) {
    const headers = this.extractHeaders(message.payload.headers);
    const body = this.extractBody(message.payload);
    
    return {
      id: message.id,
      threadId: message.threadId,
      from: headers.from || '',
      to: headers.to || '',
      subject: headers.subject || '',
      date: headers.date || '',
      body: body.text || body.html || '',
      bodyText: body.text,
      bodyHtml: body.html,
      snippet: message.snippet || ''
    };
  }

  /**
   * Check if email is a catering inquiry
   */
  static isCateringInquiry(parsedEmail) {
    const keywords = [
      'catering', 'veranstaltung', 'event', 'feier', 'party',
      'hochzeit', 'wedding', 'geburtstag', 'birthday', 'firmenevent',
      'business', 'lunch', 'buffet', 'menü', 'menu', 'gäste', 'guests',
      'personen', 'people', 'angebot', 'offer', 'anfrage', 'inquiry'
    ];

    const content = `${parsedEmail.subject} ${parsedEmail.body}`.toLowerCase();
    return keywords.some(keyword => content.includes(keyword));
  }

  /**
   * Extract guest count from email
   */
  static extractGuestCount(text) {
    const patterns = [
      /(\d+)\s*(?:personen|people|gäste|guests)/i,
      /(?:für|for)\s*(\d+)\s*(?:personen|people|gäste|guests)?/i,
      /(\d+)\s*(?:teilnehmer|attendees|participants)/i
    ];

    for (const pattern of patterns) {
      const match = text.match(pattern);
      if (match && match[1]) {
        return parseInt(match[1]);
      }
    }
    return null;
  }

  /**
   * Extract event date from email
   */
  static extractEventDate(text) {
    const patterns = [
      /(\d{1,2})\.\s*(\d{1,2})\.\s*(\d{4})/,  // German format: DD.MM.YYYY
      /(\d{1,2})\/(\d{1,2})\/(\d{4})/,         // US format: MM/DD/YYYY
      /(\d{4})-(\d{2})-(\d{2})/                // ISO format: YYYY-MM-DD
    ];

    for (const pattern of patterns) {
      const match = text.match(pattern);
      if (match) {
        return match[0];
      }
    }
    return null;
  }
}

module.exports = EmailParser;