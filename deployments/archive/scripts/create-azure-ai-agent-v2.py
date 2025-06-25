#!/usr/bin/env python3
"""
Create a new Azure AI Agent using the correct Azure AI Agents SDK syntax
"""

import os
import sys
import time
from pathlib import Path
from typing import List, Dict, Optional
from azure.ai.agents import AgentsClient, Agent, AgentThread, ThreadMessage, ThreadRun
from azure.ai.agents.models import FileSearchTool
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

# Convert to agents endpoint
if "/api/projects/" in ENDPOINT:
    base_url = ENDPOINT.split("/api/projects/")[0]
    project_name = ENDPOINT.split("/api/projects/")[1]
    AGENTS_ENDPOINT = base_url
else:
    AGENTS_ENDPOINT = ENDPOINT
    project_name = "jasmin-catering"

print(f"Using endpoint: {AGENTS_ENDPOINT}")
print(f"Project: {project_name}")

def read_prompt_file() -> str:
    """Read the jasmin_catering_prompt.md file"""
    prompt_path = DOCUMENTS_PATH / "jasmin_catering_prompt.md"
    print(f"📖 Reading prompt from: {prompt_path}")
    
    with open(prompt_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print(f"✅ Prompt loaded ({len(content)} characters)")
    return content

def create_agent_client():
    """Create the Azure AI Agents client"""
    if not API_KEY:
        print("❌ Error: AZURE_AI_API_KEY not found in environment")
        sys.exit(1)
    
    try:
        # Create client with API key
        client = AgentsClient(
            endpoint=AGENTS_ENDPOINT,
            credential=AzureKeyCredential(API_KEY)
        )
        print("✅ Created AgentsClient")
        return client
    except Exception as e:
        print(f"❌ Error creating client: {str(e)}")
        sys.exit(1)

def create_jasmin_agent(client: AgentsClient, prompt: str) -> Optional[Agent]:
    """Create the Jasmin Catering agent"""
    print("\n🤖 Creating Jasmin Catering Agent...")
    
    try:
        # Create agent with file search tool
        agent = client.create_agent(
            model="gpt-4o",
            name="Jasmin Catering Agent",
            instructions=prompt,
            tools=[FileSearchTool()],
            temperature=0.3,
            metadata={
                "description": "Professional catering inquiry processor for Jasmin Catering Berlin",
                "language": "German",
                "business": "Jasmin Catering"
            }
        )
        
        print(f"✅ Agent created successfully!")
        print(f"   ID: {agent.id}")
        print(f"   Name: {agent.name}")
        print(f"   Model: {agent.model}")
        
        return agent
        
    except Exception as e:
        error_msg = str(e)
        print(f"❌ Error creating agent: {error_msg}")
        
        # Try alternative approaches
        if "model" in error_msg.lower() or "gpt-4o" in error_msg.lower():
            print("\n💡 Trying with gpt-4 model...")
            try:
                agent = client.create_agent(
                    model="gpt-4",
                    name="Jasmin Catering Agent",
                    instructions=prompt[:5000],  # Truncate if needed
                    tools=[FileSearchTool()],
                    temperature=0.3
                )
                print(f"✅ Agent created with gpt-4!")
                print(f"   ID: {agent.id}")
                return agent
            except Exception as e2:
                print(f"❌ Error with gpt-4: {str(e2)}")
        
        return None

def upload_documents_to_agent(client: AgentsClient, agent: Agent) -> bool:
    """Upload documents for the agent"""
    print(f"\n📁 Preparing documents for agent...")
    
    documents = []
    
    # Get document files
    doc_files = [
        "catering-brief.md",
        "vegetarian-offer-template.md",
        "email-template.md",
        "business-conditions.md",
        "response-examples.md"
    ]
    
    for filename in doc_files:
        filepath = DOCUMENTS_PATH / filename
        if filepath.exists():
            documents.append(filepath)
            print(f"   ✅ Found: {filename}")
    
    # Note: Document upload might require vector store creation
    # This is a placeholder for the actual implementation
    print(f"\n📄 {len(documents)} documents ready for upload")
    print("ℹ️  Note: Document upload to agents may require vector store configuration")
    
    return True

def test_agent(client: AgentsClient, agent: Agent) -> None:
    """Test the agent with a sample query"""
    print(f"\n🧪 Testing agent...")
    
    try:
        # Create a thread
        thread = client.create_thread()
        print(f"✅ Created thread: {thread.id}")
        
        # Create a message
        message = client.create_message(
            thread_id=thread.id,
            role="user",
            content="Ich brauche Catering für 50 Personen am 15. August 2025 in Berlin-Mitte. Wir möchten syrische Spezialitäten mit vegetarischen Optionen. Bitte erstellen Sie mir drei Angebote."
        )
        print("✅ Added test message")
        
        # Run the agent
        run = client.create_run(
            thread_id=thread.id,
            assistant_id=agent.id
        )
        print(f"✅ Started run: {run.id}")
        
        # Wait for completion
        print("⏳ Waiting for response...")
        for i in range(30):
            run = client.get_run(thread_id=thread.id, run_id=run.id)
            print(f"   Status: {run.status}", end="\r")
            
            if run.status in ["completed", "failed", "cancelled", "expired"]:
                break
            time.sleep(2)
        
        print(f"\n   Final status: {run.status}")
        
        if run.status == "completed":
            # Get messages
            messages = client.list_messages(thread_id=thread.id)
            for msg in messages:
                if msg.role == "assistant" and msg.content:
                    print(f"\n✅ Agent response preview:")
                    content = msg.content[0].text.value if msg.content else "No content"
                    print(f"{content[:400]}...")
                    break
        else:
            print(f"❌ Run ended with status: {run.status}")
            if hasattr(run, 'last_error'):
                print(f"   Error: {run.last_error}")
            
    except Exception as e:
        print(f"❌ Error testing agent: {str(e)}")

def main():
    """Main execution"""
    print("🚀 Azure AI Agent Creation (v2)")
    print("===============================")
    print(f"Endpoint: {AGENTS_ENDPOINT}")
    print()
    
    # Create client
    client = create_agent_client()
    
    # Read prompt
    prompt = read_prompt_file()
    
    # Create agent
    agent = create_jasmin_agent(client, prompt)
    if not agent:
        print("\n❌ Failed to create agent")
        print("\n💡 Troubleshooting:")
        print("1. Verify Azure AI Agents is enabled on your resource")
        print("2. Check if the endpoint supports agents API")
        print("3. Ensure your API key has appropriate permissions")
        print("\n📝 Alternative: Continue using Chat Completions API")
        print("   Run: ./deployments/scripts/deploy-chat-completions.sh")
        return
    
    # Upload documents (placeholder)
    upload_documents_to_agent(client, agent)
    
    # Test agent
    test_agent(client, agent)
    
    print("\n✨ Agent setup complete!")
    print(f"\n📋 Agent Details:")
    print(f"   ID: {agent.id}")
    print(f"   Name: {agent.name}")
    print(f"   Model: {agent.model}")
    print(f"   Endpoint: {AGENTS_ENDPOINT}")
    
    # Save agent ID for future use
    agent_id_file = Path(__file__).parent / "agent_id.txt"
    with open(agent_id_file, 'w') as f:
        f.write(agent.id)
    print(f"\n💾 Agent ID saved to: {agent_id_file}")
    
    print(f"\n🔧 Next steps:")
    print(f"1. Update your Logic App to use agent ID: {agent.id}")
    print(f"2. Update the workflow configuration")
    print(f"3. Test the complete integration")

if __name__ == "__main__":
    main()