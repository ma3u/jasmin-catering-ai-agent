#!/usr/bin/env python3
"""
Configure OpenAI Assistant with prompt and upload documents to vector store
Uses Azure AI Python SDK to update assistant configuration
"""

import os
import sys
import time
from pathlib import Path
from typing import List, Dict
from openai import AzureOpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
ASSISTANT_ID = "asst_MN5PHipyHYPXyq3fENx7V20j"
DOCUMENTS_PATH = Path(__file__).parent.parent / "documents"
TEMPLATES_PATH = Path(__file__).parent.parent / "templates"

# Azure OpenAI configuration
# Use Azure AI Foundry endpoint from environment
azure_endpoint = os.getenv("AZURE_AI_ENDPOINT", "https://jasmin-catering-resource.services.ai.azure.com/api/projects/jasmin-catering")

# For OpenAI API compatibility, we need the base URL without project path
if "/api/projects/" in azure_endpoint:
    # Extract base URL for OpenAI client
    base_url = azure_endpoint.split("/api/projects/")[0]
    azure_endpoint = base_url.replace(".services.ai.azure.com", ".cognitiveservices.azure.com")

client = AzureOpenAI(
    api_key=os.getenv("AZURE_AI_API_KEY"),
    api_version="2024-02-01",
    azure_endpoint=azure_endpoint
)

def read_prompt_file() -> str:
    """Read the jasmin_catering_prompt.md file"""
    prompt_path = DOCUMENTS_PATH / "jasmin_catering_prompt.md"
    print(f"📖 Reading prompt from: {prompt_path}")
    
    with open(prompt_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print(f"✅ Prompt loaded ({len(content)} characters)")
    return content

def get_documents_to_upload() -> List[Dict[str, str]]:
    """Get list of documents to upload to vector store"""
    documents = []
    
    # Documents from deployments/documents
    doc_files = [
        "catering-brief.md",
        "vegetarian-offer-template.md", 
        "email-template.md",
        "business-conditions.md",
        "response-examples.md"
    ]
    
    # Templates from deployments/templates
    template_files = [
        "order-templates.md",
        "company-policies.md"
    ]
    
    # Add document files
    for filename in doc_files:
        filepath = DOCUMENTS_PATH / filename
        if filepath.exists():
            documents.append({
                "path": str(filepath),
                "name": filename,
                "purpose": "assistants"
            })
    
    # Add template files if they exist
    for filename in template_files:
        filepath = TEMPLATES_PATH / filename
        if filepath.exists():
            documents.append({
                "path": str(filepath),
                "name": filename,
                "purpose": "assistants"
            })
    
    # Add project documentation
    project_root = Path(__file__).parent.parent.parent
    for filename in ["README.md", "CLAUDE.md"]:
        filepath = project_root / filename
        if filepath.exists():
            documents.append({
                "path": str(filepath),
                "name": filename,
                "purpose": "assistants"
            })
    
    return documents

def update_assistant_configuration(prompt: str) -> None:
    """Update assistant configuration with new prompt"""
    print(f"\n🤖 Updating assistant: {ASSISTANT_ID}")
    
    try:
        # Update assistant instructions
        assistant = client.beta.assistants.update(
            assistant_id=ASSISTANT_ID,
            instructions=prompt,
            name="Jasmin Catering Agent",
            description="Professional catering inquiry processor for Jasmin Catering Berlin",
            model="gpt-4o",
            tools=[{"type": "file_search"}],  # Enable RAG with file search
            temperature=0.3
        )
        
        print(f"✅ Assistant updated successfully")
        print(f"   - Name: {assistant.name}")
        print(f"   - Model: {assistant.model}")
        print(f"   - Tools: {[tool.type for tool in assistant.tools]}")
        
    except Exception as e:
        print(f"❌ Error updating assistant: {str(e)}")
        sys.exit(1)

def upload_documents_to_vector_store(documents: List[Dict[str, str]]) -> None:
    """Upload documents to assistant's vector store"""
    print(f"\n📁 Uploading {len(documents)} documents to vector store...")
    
    try:
        # Get existing assistant
        assistant = client.beta.assistants.retrieve(ASSISTANT_ID)
        
        # Create a vector store if needed
        vector_store = client.beta.vector_stores.create(
            name="Jasmin Catering Knowledge Base"
        )
        print(f"✅ Created vector store: {vector_store.id}")
        
        # Upload each document
        file_ids = []
        for doc in documents:
            print(f"\n📄 Uploading: {doc['name']}")
            
            # Upload file
            with open(doc['path'], 'rb') as f:
                file = client.files.create(
                    file=f,
                    purpose=doc['purpose']
                )
            file_ids.append(file.id)
            print(f"   ✅ File ID: {file.id}")
        
        # Add files to vector store
        print(f"\n🔗 Adding files to vector store...")
        for file_id in file_ids:
            client.beta.vector_stores.files.create(
                vector_store_id=vector_store.id,
                file_id=file_id
            )
        
        # Update assistant with vector store
        client.beta.assistants.update(
            assistant_id=ASSISTANT_ID,
            tool_resources={
                "file_search": {
                    "vector_store_ids": [vector_store.id]
                }
            }
        )
        
        print(f"\n✅ Vector store attached to assistant")
        print(f"   - Store ID: {vector_store.id}")
        print(f"   - Files: {len(file_ids)}")
        
    except Exception as e:
        print(f"❌ Error uploading documents: {str(e)}")
        sys.exit(1)

def test_assistant_configuration() -> None:
    """Test the assistant with a sample query"""
    print(f"\n🧪 Testing assistant configuration...")
    
    try:
        # Create a test thread
        thread = client.beta.threads.create()
        
        # Add test message
        message = client.beta.threads.messages.create(
            thread_id=thread.id,
            role="user",
            content="Ich brauche Catering für 50 Personen am 15. August 2025 in Berlin-Mitte. Bitte erstellen Sie mir drei Angebote."
        )
        
        # Run the assistant
        run = client.beta.threads.runs.create(
            thread_id=thread.id,
            assistant_id=ASSISTANT_ID
        )
        
        # Wait for completion
        print("   ⏳ Waiting for response...")
        while run.status in ["queued", "in_progress"]:
            time.sleep(2)
            run = client.beta.threads.runs.retrieve(
                thread_id=thread.id,
                run_id=run.id
            )
        
        if run.status == "completed":
            # Get messages
            messages = client.beta.threads.messages.list(thread_id=thread.id)
            assistant_message = next((m for m in messages.data if m.role == "assistant"), None)
            
            if assistant_message:
                print("   ✅ Test successful!")
                print(f"   📝 Response preview: {assistant_message.content[0].text.value[:200]}...")
            else:
                print("   ⚠️ No assistant response found")
        else:
            print(f"   ❌ Run failed with status: {run.status}")
            
    except Exception as e:
        print(f"❌ Error testing assistant: {str(e)}")

def main():
    """Main execution function"""
    print("🚀 Jasmin Catering Assistant Configuration")
    print("==========================================")
    
    # Check environment variables
    if not os.getenv("AZURE_AI_API_KEY"):
        print("❌ Error: AZURE_AI_API_KEY not found in environment")
        sys.exit(1)
    
    # Step 1: Read prompt
    prompt = read_prompt_file()
    
    # Step 2: Get documents to upload
    documents = get_documents_to_upload()
    print(f"\n📚 Found {len(documents)} documents to upload:")
    for doc in documents:
        print(f"   - {doc['name']}")
    
    # Step 3: Update assistant configuration
    update_assistant_configuration(prompt)
    
    # Step 4: Upload documents to vector store
    upload_documents_to_vector_store(documents)
    
    # Step 5: Test the configuration
    test_assistant_configuration()
    
    print("\n✨ Assistant configuration complete!")
    print(f"   - Assistant ID: {ASSISTANT_ID}")
    print("   - Prompt: Updated with jasmin_catering_prompt.md")
    print(f"   - Documents: {len(documents)} files uploaded to RAG")
    print("\n📊 The assistant is now ready to process catering inquiries!")

if __name__ == "__main__":
    main()