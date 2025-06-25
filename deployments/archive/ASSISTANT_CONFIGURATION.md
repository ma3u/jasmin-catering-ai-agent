# OpenAI Assistant Configuration Guide

This document explains how to configure the OpenAI Assistant `asst_MN5PHipyHYPXyq3fENx7V20j` with the Jasmin Catering prompt and RAG documents.

## Overview

The assistant is configured with:
1. **Custom Instructions**: From `jasmin_catering_prompt.md`
2. **RAG Knowledge Base**: Multiple documents uploaded to vector store
3. **File Search**: Enabled for retrieval-augmented generation

## Prerequisites

1. **Python 3.8+** installed
2. **Required packages**:
   ```bash
   pip install -r requirements.txt
   ```
3. **Environment variables** in `.env`:
   - `AZURE_AI_API_KEY`
   - `AZURE_AI_ENDPOINT` (optional, defaults to jasmin-catering-resource)

## Configuration Script

### Usage
```bash
# From project root
python deployments/scripts/configure-assistant.py
```

### What it does:
1. **Reads** the prompt from `deployments/documents/jasmin_catering_prompt.md`
2. **Updates** the assistant instructions with the prompt
3. **Creates** a vector store named "Jasmin Catering Knowledge Base"
4. **Uploads** documents to the vector store:
   - All `.md` files from `deployments/documents/`
   - Template files from `deployments/templates/`
   - Project documentation (README.md, CLAUDE.md)
5. **Attaches** the vector store to the assistant
6. **Tests** the configuration with a sample query

## Documents Uploaded to RAG

### Core Documents (`deployments/documents/`)
- **catering-brief.md**: Business process logic, 3-package system
- **vegetarian-offer-template.md**: Complete menu items with prices
- **email-template.md**: Professional email templates
- **business-conditions.md**: Legal terms, company data
- **response-examples.md**: Example responses for different events

### Templates (`deployments/templates/`)
- **order-templates.md**: Confirmation and response templates
- **company-policies.md**: Service standards, pricing guidelines

### Project Documentation
- **README.md**: Complete system documentation
- **CLAUDE.md**: AI agent best practices

## Manual Configuration (Alternative)

If you prefer to configure manually via Azure Portal or API:

### 1. Update Assistant Instructions
```python
import os
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key=os.getenv("AZURE_AI_API_KEY"),
    api_version="2024-02-01",
    azure_endpoint="https://jasmin-catering-resource.cognitiveservices.azure.com"
)

# Read prompt
with open("deployments/documents/jasmin_catering_prompt.md", "r") as f:
    prompt = f.read()

# Update assistant
assistant = client.beta.assistants.update(
    assistant_id="asst_MN5PHipyHYPXyq3fENx7V20j",
    instructions=prompt,
    tools=[{"type": "file_search"}]
)
```

### 2. Create Vector Store and Upload Files
```python
# Create vector store
vector_store = client.beta.vector_stores.create(
    name="Jasmin Catering Knowledge Base"
)

# Upload files
file_paths = [
    "deployments/documents/catering-brief.md",
    "deployments/documents/vegetarian-offer-template.md",
    # ... more files
]

file_ids = []
for path in file_paths:
    with open(path, "rb") as f:
        file = client.files.create(file=f, purpose="assistants")
        file_ids.append(file.id)

# Add files to vector store
for file_id in file_ids:
    client.beta.vector_stores.files.create(
        vector_store_id=vector_store.id,
        file_id=file_id
    )

# Attach to assistant
client.beta.assistants.update(
    assistant_id="asst_MN5PHipyHYPXyq3fENx7V20j",
    tool_resources={
        "file_search": {
            "vector_store_ids": [vector_store.id]
        }
    }
)
```

## Testing the Assistant

After configuration, test with:

```python
# Create thread
thread = client.beta.threads.create()

# Add message
message = client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="Ich brauche Catering für 50 Personen am 15. August in Berlin."
)

# Run assistant
run = client.beta.threads.runs.create(
    thread_id=thread.id,
    assistant_id="asst_MN5PHipyHYPXyq3fENx7V20j"
)
```

## Expected Behavior

The configured assistant will:
1. **Extract** event details from German catering inquiries
2. **Search** the vector store for relevant menu items and pricing
3. **Generate** three package offers (Basis, Standard, Premium)
4. **Format** responses using professional email templates
5. **Include** authentic Syrian menu items from the knowledge base
6. **Apply** correct pricing based on company policies

## Troubleshooting

### Common Issues

1. **API Key Error**
   - Ensure `AZURE_AI_API_KEY` is set in `.env`
   - Check key has correct permissions

2. **File Upload Fails**
   - Verify file paths exist
   - Check file sizes (max 512MB per file)

3. **Assistant Not Found**
   - Verify assistant ID: `asst_MN5PHipyHYPXyq3fENx7V20j`
   - Ensure API key has access to the assistant

4. **No RAG Results**
   - Check vector store is attached
   - Verify files were uploaded successfully
   - Test with explicit file search queries

## Monitoring

After configuration:
- **Assistant ID**: `asst_MN5PHipyHYPXyq3fENx7V20j`
- **Model**: GPT-4o
- **Tools**: file_search (RAG enabled)
- **Temperature**: 0.3 (consistent responses)
- **Vector Store**: Contains 9+ documents

The assistant is now ready to process catering inquiries with full RAG support!