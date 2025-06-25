#!/usr/bin/env python3
"""
Upload documents using OpenAI SDK directly
This approach uses the OpenAI-compatible endpoints
"""

import os
from pathlib import Path
from openai import AzureOpenAI
from dotenv import load_dotenv

load_dotenv()

# Configuration
AGENT_ID = "asst_xaWmWbwVkjLslHiRrg9teIP0"
client = AzureOpenAI(
    api_key=os.getenv("AZURE_AI_API_KEY"),
    api_version="2024-02-01",
    azure_endpoint="https://jasmin-catering-resource.cognitiveservices.azure.com"
)

# Create vector store
vector_store = client.beta.vector_stores.create(
    name="Jasmin Catering Knowledge Base"
)

# Upload files
documents_path = Path(__file__).parent.parent / "documents"
for file_path in documents_path.glob("*.md"):
    print(f"Uploading: {file_path.name}")
    with open(file_path, "rb") as f:
        file = client.files.create(file=f, purpose="assistants")
        client.beta.vector_stores.files.create(
            vector_store_id=vector_store.id,
            file_id=file.id
        )

# Attach to assistant
client.beta.assistants.update(
    assistant_id=AGENT_ID,
    tool_resources={
        "file_search": {
            "vector_store_ids": [vector_store.id]
        }
    }
)

print(f"✅ Vector store {vector_store.id} attached to agent!")
