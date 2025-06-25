#!/usr/bin/env python3
"""
Create a new Azure AI Agent using the Azure AI Agents SDK
This creates an agent in Azure AI Foundry with the Jasmin Catering configuration
"""

import os
import sys
import time
from pathlib import Path
from typing import List, Dict, Optional
from azure.ai.agents import AgentsClient
from azure.identity import DefaultAzureCredential
from azure.core.credentials import AzureKeyCredential
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
DOCUMENTS_PATH = Path(__file__).parent.parent / "documents"
TEMPLATES_PATH = Path(__file__).parent.parent / "templates"

# Azure AI configuration
API_KEY = os.getenv("AZURE_AI_API_KEY")
ENDPOINT = os.getenv("AZURE_AI_ENDPOINT", "https://jasmin-catering-resource.services.ai.azure.com")

# Extract the connection string format
# Azure AI Agents expects format: https://<resource>.services.ai.azure.com/ai-agents
if "/api/projects/" in ENDPOINT:
    # Convert project endpoint to agents endpoint
    base_url = ENDPOINT.split("/api/projects/")[0]
    AGENTS_ENDPOINT = f"{base_url}/ai-agents"
else:
    AGENTS_ENDPOINT = f"{ENDPOINT}/ai-agents"

print(f"Using endpoint: {AGENTS_ENDPOINT}")

def read_prompt_file() -> str:
    """Read the jasmin_catering_prompt.md file"""
    prompt_path = DOCUMENTS_PATH / "jasmin_catering_prompt.md"
    print(f"📖 Reading prompt from: {prompt_path}")
    
    with open(prompt_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print(f"✅ Prompt loaded ({len(content)} characters)")
    return content

def get_documents_to_upload() -> List[Dict[str, str]]:
    """Get list of documents to upload"""
    documents = []
    
    # Core documents
    doc_files = [
        "catering-brief.md",
        "vegetarian-offer-template.md", 
        "email-template.md",
        "business-conditions.md",
        "response-examples.md"
    ]
    
    # Template files
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
                "content": filepath.read_text(encoding='utf-8')
            })
    
    # Add template files
    for filename in template_files:
        filepath = TEMPLATES_PATH / filename
        if filepath.exists():
            documents.append({
                "path": str(filepath),
                "name": filename,
                "content": filepath.read_text(encoding='utf-8')
            })
    
    return documents

def create_agent_client():
    """Create the Azure AI Agents client"""
    if not API_KEY:
        print("❌ Error: AZURE_AI_API_KEY not found in environment")
        sys.exit(1)
    
    try:
        # Try with API key credential
        credential = AzureKeyCredential(API_KEY)
        client = AgentsClient(endpoint=AGENTS_ENDPOINT, credential=credential)
        print("✅ Created AgentsClient with API key")
        return client
    except Exception as e:
        print(f"❌ Error creating client: {str(e)}")
        print("\nTrying alternative authentication...")
        
        # Try with DefaultAzureCredential
        try:
            credential = DefaultAzureCredential()
            client = AgentsClient(endpoint=AGENTS_ENDPOINT, credential=credential)
            print("✅ Created AgentsClient with Azure credential")
            return client
        except Exception as e2:
            print(f"❌ Error with Azure credential: {str(e2)}")
            sys.exit(1)

def create_jasmin_agent(client: AgentsClient, prompt: str) -> Optional[str]:
    """Create the Jasmin Catering agent"""
    print("\n🤖 Creating Jasmin Catering Agent...")
    
    try:
        # Create agent configuration
        agent_config = {
            "name": "Jasmin Catering Agent",
            "instructions": prompt,
            "model": "gpt-4o",
            "description": "Professional catering inquiry processor for Jasmin Catering Berlin",
            "temperature": 0.3,
            "tools": [
                {"type": "file_search"}  # Enable file search for RAG
            ]
        }
        
        # Create the agent
        agent = client.agents.create(**agent_config)
        
        print(f"✅ Agent created successfully!")
        print(f"   ID: {agent.id}")
        print(f"   Name: {agent.name}")
        print(f"   Model: {agent.model}")
        
        return agent.id
        
    except Exception as e:
        print(f"❌ Error creating agent: {str(e)}")
        
        # If error contains model info, suggest alternatives
        if "model" in str(e).lower():
            print("\n💡 Trying with alternative model...")
            agent_config["model"] = "gpt-35-turbo"
            try:
                agent = client.agents.create(**agent_config)
                print(f"✅ Agent created with gpt-35-turbo!")
                print(f"   ID: {agent.id}")
                return agent.id
            except Exception as e2:
                print(f"❌ Error with alternative model: {str(e2)}")
        
        return None

def upload_documents_to_agent(client: AgentsClient, agent_id: str, documents: List[Dict[str, str]]) -> bool:
    """Upload documents to agent's file store"""
    print(f"\n📁 Uploading {len(documents)} documents to agent...")
    
    try:
        # Create a file store for the agent
        file_store = client.agents.file_stores.create(
            name="Jasmin Catering Knowledge Base",
            metadata={"agent_id": agent_id}
        )
        print(f"✅ Created file store: {file_store.id}")
        
        # Upload each document
        file_ids = []
        for doc in documents:
            print(f"📄 Uploading: {doc['name']}")
            try:
                # Upload file content
                file_response = client.agents.files.upload(
                    content=doc['content'].encode('utf-8'),
                    filename=doc['name'],
                    purpose="assistants"
                )
                file_ids.append(file_response.id)
                print(f"   ✅ Uploaded: {file_response.id}")
            except Exception as e:
                print(f"   ❌ Error: {str(e)}")
        
        # Associate files with agent
        if file_ids:
            print(f"\n🔗 Associating {len(file_ids)} files with agent...")
            client.agents.update(
                agent_id=agent_id,
                file_ids=file_ids
            )
            print("✅ Files associated with agent")
        
        return True
        
    except Exception as e:
        print(f"❌ Error uploading documents: {str(e)}")
        return False

def test_agent(client: AgentsClient, agent_id: str) -> None:
    """Test the agent with a sample query"""
    print(f"\n🧪 Testing agent...")
    
    try:
        # Create a thread
        thread = client.agents.threads.create()
        print(f"✅ Created thread: {thread.id}")
        
        # Add a message
        message = client.agents.threads.messages.create(
            thread_id=thread.id,
            role="user",
            content="Ich brauche Catering für 50 Personen am 15. August 2025 in Berlin-Mitte. Bitte erstellen Sie mir drei Angebote."
        )
        print("✅ Added test message")
        
        # Run the agent
        run = client.agents.threads.runs.create(
            thread_id=thread.id,
            agent_id=agent_id
        )
        print(f"✅ Started run: {run.id}")
        
        # Wait for completion
        print("⏳ Waiting for response...")
        max_attempts = 30
        for _ in range(max_attempts):
            run = client.agents.threads.runs.retrieve(
                thread_id=thread.id,
                run_id=run.id
            )
            if run.status in ["completed", "failed", "cancelled"]:
                break
            time.sleep(2)
        
        if run.status == "completed":
            # Get messages
            messages = client.agents.threads.messages.list(thread_id=thread.id)
            for msg in messages.data:
                if msg.role == "assistant":
                    print(f"\n✅ Agent response preview:")
                    print(f"{msg.content[0].text.value[:300]}...")
                    break
        else:
            print(f"❌ Run ended with status: {run.status}")
            
    except Exception as e:
        print(f"❌ Error testing agent: {str(e)}")

def main():
    """Main execution"""
    print("🚀 Azure AI Agent Creation")
    print("==========================")
    print(f"Endpoint: {AGENTS_ENDPOINT}")
    print()
    
    # Create client
    client = create_agent_client()
    
    # Read prompt
    prompt = read_prompt_file()
    
    # Get documents
    documents = get_documents_to_upload()
    print(f"\n📚 Found {len(documents)} documents to upload:")
    for doc in documents:
        print(f"   - {doc['name']}")
    
    # Create agent
    agent_id = create_jasmin_agent(client, prompt)
    if not agent_id:
        print("\n❌ Failed to create agent")
        print("\n💡 Alternatives:")
        print("1. Check if Azure AI Agents is enabled on your resource")
        print("2. Use the existing Logic App with Chat Completions API")
        print("3. Try creating agent via Azure AI Studio portal")
        return
    
    # Upload documents
    upload_documents_to_agent(client, agent_id, documents)
    
    # Test agent
    test_agent(client, agent_id)
    
    print("\n✨ Agent creation complete!")
    print(f"\n📋 Agent Details:")
    print(f"   ID: {agent_id}")
    print(f"   Name: Jasmin Catering Agent")
    print(f"   Endpoint: {AGENTS_ENDPOINT}")
    print(f"\n🔧 Update your Logic App to use this agent ID: {agent_id}")
    print(f"\n📝 Next steps:")
    print(f"1. Update ASSISTANT_ID in your configuration to: {agent_id}")
    print(f"2. Run: ./deployments/scripts/update-to-assistant.sh")
    print(f"3. Monitor with: ./deployments/scripts/monitor-logic-app.sh")

if __name__ == "__main__":
    main()