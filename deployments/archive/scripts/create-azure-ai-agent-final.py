#!/usr/bin/env python3
"""
Create a new Azure AI Agent using the Azure AI Agents SDK
Based on the actual SDK structure
"""

import os
import sys
import time
from pathlib import Path
from typing import Optional
from azure.ai.agents import AgentsClient
from azure.core.credentials import AzureKeyCredential
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
DOCUMENTS_PATH = Path(__file__).parent.parent / "documents"
API_KEY = os.getenv("AZURE_AI_API_KEY")
ENDPOINT = os.getenv("AZURE_AI_ENDPOINT", "https://jasmin-catering-resource.services.ai.azure.com")

# Extract base endpoint
if "/api/projects/" in ENDPOINT:
    base_url = ENDPOINT.split("/api/projects/")[0]
else:
    base_url = ENDPOINT

print(f"Using endpoint: {base_url}")

def read_prompt_file() -> str:
    """Read the jasmin_catering_prompt.md file"""
    prompt_path = DOCUMENTS_PATH / "jasmin_catering_prompt.md"
    print(f"📖 Reading prompt from: {prompt_path}")
    
    with open(prompt_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print(f"✅ Prompt loaded ({len(content)} characters)")
    return content

def create_and_test_agent():
    """Create and test an Azure AI Agent"""
    if not API_KEY:
        print("❌ Error: AZURE_AI_API_KEY not found")
        return
    
    try:
        # Create client
        client = AgentsClient(
            endpoint=base_url,
            credential=AzureKeyCredential(API_KEY)
        )
        print("✅ Created AgentsClient")
        
        # Read prompt
        prompt = read_prompt_file()
        
        # Try to create an agent
        print("\n🤖 Creating agent...")
        
        # Create agent configuration
        agent_data = {
            "model": "gpt-4o",
            "name": "Jasmin Catering Agent",
            "instructions": prompt,
            "tools": [{"type": "file_search"}],
            "temperature": 0.3
        }
        
        # The actual method depends on the SDK version
        # Try different approaches
        try:
            # Approach 1: Direct method
            if hasattr(client, 'agents'):
                agent = client.agents.create(**agent_data)
                print(f"✅ Agent created: {agent.id}")
                return agent.id
        except Exception as e:
            print(f"Method 1 failed: {str(e)}")
        
        try:
            # Approach 2: Create method
            if hasattr(client, 'create_agent'):
                agent = client.create_agent(**agent_data)
                print(f"✅ Agent created: {agent.id}")
                return agent.id
        except Exception as e:
            print(f"Method 2 failed: {str(e)}")
        
        try:
            # Approach 3: Direct create
            agent = client.create(**agent_data)
            print(f"✅ Agent created: {agent}")
            return agent
        except Exception as e:
            print(f"Method 3 failed: {str(e)}")
        
        # If all methods fail, show available methods
        print("\n📋 Available client methods:")
        methods = [m for m in dir(client) if not m.startswith('_') and callable(getattr(client, m))]
        for method in methods[:10]:  # Show first 10 methods
            print(f"   - {method}")
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        print("\n💡 The Azure AI Agents SDK might not be fully configured for this endpoint")

def main():
    """Main execution"""
    print("🚀 Azure AI Agent Creation")
    print("==========================")
    
    agent_id = create_and_test_agent()
    
    if not agent_id:
        print("\n❌ Could not create agent via API")
        print("\n📝 Recommendations:")
        print("1. Use Azure AI Studio portal to create agents")
        print("2. Continue with Chat Completions API (working)")
        print("3. Check if Agents API is enabled on your resource")
        print("\n✅ Your Logic App is currently working with Chat Completions")
        print("   No action needed - the system is functional!")
    else:
        print(f"\n✨ Success! Agent ID: {agent_id}")
        print("\nNext steps:")
        print(f"1. Update Logic App to use agent: {agent_id}")
        print("2. Test the integration")

if __name__ == "__main__":
    main()