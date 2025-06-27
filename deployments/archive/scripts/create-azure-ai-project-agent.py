#!/usr/bin/env python3
"""
Create Azure AI Agent using Azure AI Projects SDK
Based on official Azure SDK samples
"""

import os
import sys
from pathlib import Path
from azure.ai.projects import AIProjectClient
from azure.ai.agents.models import ToolSet, FileSearchTool
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
DOCUMENTS_PATH = Path(__file__).parent.parent / "documents"
PROJECT_ENDPOINT = os.getenv("AZURE_AI_ENDPOINT", "https://jasmin-catering-resource.services.ai.azure.com/api/projects/jasmin-catering")
MODEL_DEPLOYMENT = "gpt-4o"  # The deployment name from your Azure AI resource

print(f"📍 Project Endpoint: {PROJECT_ENDPOINT}")
print(f"🤖 Model Deployment: {MODEL_DEPLOYMENT}")

def read_prompt_file() -> str:
    """Read the jasmin_catering_prompt.md file"""
    prompt_path = DOCUMENTS_PATH / "jasmin_catering_prompt.md"
    print(f"\n📖 Reading prompt from: {prompt_path}")
    
    with open(prompt_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print(f"✅ Prompt loaded ({len(content)} characters)")
    return content

def create_jasmin_agent():
    """Create the Jasmin Catering agent using AI Projects SDK"""
    try:
        # Create the AI Project client
        print("\n🔧 Creating AI Project client...")
        
        # Use DefaultAzureCredential for authentication
        credential = DefaultAzureCredential()
        
        project_client = AIProjectClient(
            endpoint=PROJECT_ENDPOINT,
            credential=credential
        )
        print("✅ AI Project client created")
        
        # Read the prompt
        prompt = read_prompt_file()
        
        with project_client:
            agents_client = project_client.agents
            
            # Create toolset with file search
            print("\n🛠️ Setting up tools...")
            tools = [{"type": "file_search"}]
            print("✅ File search tool configured")
            
            # Create the agent
            print("\n🤖 Creating Jasmin Catering Agent...")
            agent = agents_client.create_agent(
                model=MODEL_DEPLOYMENT,
                name="Jasmin Catering Agent",
                instructions=prompt,
                tools=tools,
                temperature=0.3,
                metadata={
                    "business": "Jasmin Catering",
                    "language": "German",
                    "type": "catering-processor"
                }
            )
            
            print(f"✅ Agent created successfully!")
            print(f"   ID: {agent.id}")
            print(f"   Name: {agent.name}")
            print(f"   Model: {agent.model}")
            
            # Save agent ID
            agent_id_file = Path("agent_id.txt")
            with open(agent_id_file, 'w') as f:
                f.write(agent.id)
            print(f"\n💾 Agent ID saved to: {agent_id_file}")
            
            # Test the agent
            test_agent(agents_client, agent.id)
            
            return agent.id
            
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        
        # Check for common issues
        if "401" in str(e) or "unauthorized" in str(e).lower():
            print("\n🔐 Authentication issue detected!")
            print("   Solutions:")
            print("   1. Run: az login")
            print("   2. Check your Azure credentials")
            print("   3. Verify access to the AI Project")
        elif "404" in str(e):
            print("\n🔍 Resource not found!")
            print("   Check:")
            print("   1. Project endpoint is correct")
            print("   2. Model deployment name exists")
            print("   3. Resource is in the correct region")
        
        return None

def test_agent(agents_client, agent_id: str):
    """Test the agent with a sample query"""
    print(f"\n🧪 Testing agent...")
    
    try:
        # Create a thread
        thread = agents_client.create_thread()
        print(f"✅ Created thread: {thread.id}")
        
        # Create a message
        message = agents_client.create_message(
            thread_id=thread.id,
            role="user",
            content="Ich brauche Catering für 50 Personen am 15. August 2025 in Berlin-Mitte. Bitte erstellen Sie drei Angebote."
        )
        print("✅ Added test message")
        
        # Run the agent
        run = agents_client.create_run(
            thread_id=thread.id,
            assistant_id=agent_id
        )
        print(f"✅ Started run: {run.id}")
        print("⏳ Processing...")
        
        # Note: In production, you would poll for completion
        print("\n📝 Agent is processing the request...")
        print("   Check the thread in Azure AI Studio for results")
        
    except Exception as e:
        print(f"❌ Test error: {str(e)}")

def main():
    """Main execution"""
    print("🚀 Azure AI Project Agent Creation")
    print("==================================")
    
    # Check for required environment
    if not PROJECT_ENDPOINT:
        print("\n❌ Error: AZURE_AI_ENDPOINT not found")
        print("   Set it to your AI Project endpoint")
        return
    
    # Create the agent
    agent_id = create_jasmin_agent()
    
    if agent_id:
        print("\n✨ Success!")
        print(f"\n📋 Next Steps:")
        print(f"1. Note your agent ID: {agent_id}")
        print(f"2. Update your Logic App workflow to use this agent")
        print(f"3. The agent can be accessed via Azure AI Foundry")
        print(f"\n🔧 To update Logic App:")
        print(f"   - Edit the workflow to use agent ID: {agent_id}")
        print(f"   - Use the AI Project endpoint for API calls")
    else:
        print("\n💡 Alternative Solutions:")
        print("1. Use Azure AI Studio UI to create the agent")
        print("2. Continue with Chat Completions API (currently working)")
        print("3. Check Azure AI Foundry documentation")
        print("\n✅ Remember: Your Logic App is functional with Chat Completions!")

if __name__ == "__main__":
    # First check if we need to install azure-ai-projects
    try:
        import azure.ai.projects
    except ImportError:
        print("📦 Installing azure-ai-projects...")
        os.system("pip install --user --break-system-packages azure-ai-projects")
        print("✅ Package installed. Please run the script again.")
        sys.exit(0)
    
    main()