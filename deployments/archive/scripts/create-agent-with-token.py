#!/usr/bin/env python3
"""
Create Azure AI Agent using token-based authentication
"""

import os
from pathlib import Path
from azure.ai.agents import AgentsClient
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
DOCUMENTS_PATH = Path(__file__).parent.parent / "documents"
ENDPOINT = os.getenv("AZURE_AI_ENDPOINT", "https://jasmin-catering-resource.services.ai.azure.com")

# Extract base endpoint
if "/api/projects/" in ENDPOINT:
    base_url = ENDPOINT.split("/api/projects/")[0]
else:
    base_url = ENDPOINT

print(f"Using endpoint: {base_url}")

def main():
    """Create agent with Azure credential"""
    try:
        # Use DefaultAzureCredential for token-based auth
        credential = DefaultAzureCredential()
        client = AgentsClient(endpoint=base_url, credential=credential)
        print("✅ Created client with Azure credential")
        
        # Read prompt
        prompt_path = DOCUMENTS_PATH / "jasmin_catering_prompt.md"
        with open(prompt_path, 'r', encoding='utf-8') as f:
            prompt = f.read()
        print(f"✅ Loaded prompt ({len(prompt)} characters)")
        
        # Create agent
        print("\n🤖 Creating agent...")
        agent = client.create_agent(
            model="gpt-4o",
            name="Jasmin Catering Agent",
            instructions=prompt,
            tools=[{"type": "file_search"}],
            temperature=0.3
        )
        
        print(f"✅ Agent created!")
        print(f"   ID: {agent.id}")
        print(f"   Name: {agent.name}")
        
        # Save agent ID
        with open("agent_id.txt", "w") as f:
            f.write(agent.id)
        print(f"\n💾 Agent ID saved to: agent_id.txt")
        
        return agent.id
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        
        # If token auth fails, show alternative
        print("\n💡 Alternative: Use Azure CLI authentication")
        print("   1. Run: az login")
        print("   2. Run this script again")
        print("\n📝 Or continue with the working Chat Completions API")
        return None

if __name__ == "__main__":
    agent_id = main()
    if agent_id:
        print(f"\n✨ Success! Update your Logic App with agent ID: {agent_id}")
    else:
        print("\n✅ Your Logic App is currently working with Chat Completions API")
        print("   No urgent action needed!")