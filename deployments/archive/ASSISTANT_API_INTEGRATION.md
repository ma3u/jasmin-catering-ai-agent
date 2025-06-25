# OpenAI Assistant API Integration

This document describes the integration of OpenAI Assistant API with the Jasmin Catering Logic App.

## Overview

The Logic App has been updated to use the OpenAI Assistant API instead of the direct Chat Completions API. This provides several advantages:

- **Persistent conversation threads** - Each email creates a dedicated thread
- **Pre-configured assistant knowledge** - Uses assistant `asst_MN5PHipyHYPXyq3fENx7V20j`
- **Consistent responses** - The assistant maintains context and style
- **Better conversation management** - Threads can be reviewed and continued

## Assistant Details

- **Assistant ID**: `asst_MN5PHipyHYPXyq3fENx7V20j`
- **Purpose**: Process catering inquiries for Jasmin Catering
- **Language**: German (Deutsch)
- **Capabilities**: Generate professional catering offers with pricing

## Workflow Changes

### Previous Workflow (Chat Completions)
```
Email → Filter → Generate AI Response → Store Draft
```

### New Workflow (Assistant API)
```
Email → Filter → Create Thread → Add Message → Create Run → Wait for Completion → Get Messages → Extract Response → Store Draft
```

## API Endpoints Used

1. **Create Thread**
   ```
   POST /openai/threads
   ```

2. **Add Message to Thread**
   ```
   POST /openai/threads/{thread_id}/messages
   ```

3. **Create Run**
   ```
   POST /openai/threads/{thread_id}/runs
   Body: { "assistant_id": "asst_MN5PHipyHYPXyq3fENx7V20j" }
   ```

4. **Check Run Status**
   ```
   GET /openai/threads/{thread_id}/runs/{run_id}
   ```

5. **Get Thread Messages**
   ```
   GET /openai/threads/{thread_id}/messages
   ```

## Deployment

### Update Existing Logic App
```bash
# Run the update script
./deployments/scripts/update-to-assistant.sh
```

### Deploy New Logic App with Assistant
```bash
# Use the assistant workflow file
az logic workflow create \
  --resource-group logicapp-jasmin-sweden_group \
  --name jasmin-order-processor-sweden \
  --definition @deployments/logic-apps/email-processor-assistant-workflow.json
```

## Benefits

1. **Thread Management**: Each customer inquiry gets its own conversation thread
2. **Context Preservation**: The assistant remembers previous interactions
3. **Consistent Formatting**: Pre-configured assistant ensures consistent offer formatting
4. **Audit Trail**: Complete conversation history in threads
5. **Future Extensibility**: Easy to add follow-up messages to existing threads

## Monitoring

The Logic App now stores additional information:
- `threadId`: The conversation thread ID
- `runId`: The assistant run ID
- `draftResponse`: The generated offer

Example stored draft:
```json
{
  "emailId": "email-20250625-001",
  "threadId": "thread_abc123",
  "runId": "run_xyz789",
  "draftResponse": "Sehr geehrte Damen und Herren...",
  "processedAt": "2025-06-25T12:00:00Z",
  "status": "draft_created"
}
```

## Troubleshooting

### Common Issues

1. **Thread Creation Fails**
   - Check API key permissions
   - Verify endpoint URL includes `/openai/threads`
   - Ensure API version is `2024-02-01`

2. **Run Never Completes**
   - Check assistant ID is correct
   - Verify the assistant exists and is accessible
   - Monitor run status for error messages

3. **No Assistant Response**
   - Check the messages array for assistant role
   - Ensure the run completed successfully
   - Verify message extraction logic

## Future Enhancements

1. **Conversation Continuity**: Allow follow-up emails to use the same thread
2. **Assistant Fine-tuning**: Update assistant instructions based on feedback
3. **Multi-assistant Support**: Different assistants for different inquiry types
4. **Thread Analytics**: Track conversation metrics and response quality