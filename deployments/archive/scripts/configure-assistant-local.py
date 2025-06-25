#!/usr/bin/env python3
"""
Alternative: Create a new assistant or list existing assistants
This script helps identify if the assistant exists and creates it if needed
"""

import os
import sys
from openai import AzureOpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Azure OpenAI configuration
azure_endpoint = "https://jasmin-catering-resource.cognitiveservices.azure.com"

client = AzureOpenAI(
    api_key=os.getenv("AZURE_AI_API_KEY"),
    api_version="2024-02-01",
    azure_endpoint=azure_endpoint
)

def list_assistants():
    """List all available assistants"""
    print("\n📋 Listing all assistants...")
    try:
        assistants = client.beta.assistants.list()
        if assistants.data:
            print(f"Found {len(assistants.data)} assistants:")
            for assistant in assistants.data:
                print(f"  - ID: {assistant.id}")
                print(f"    Name: {assistant.name}")
                print(f"    Model: {assistant.model}")
                print(f"    Created: {assistant.created_at}")
                print()
        else:
            print("No assistants found.")
        return assistants.data
    except Exception as e:
        print(f"❌ Error listing assistants: {str(e)}")
        return []

def create_assistant():
    """Create a new assistant for Jasmin Catering"""
    print("\n🆕 Creating new assistant...")
    
    # Read prompt
    prompt_path = os.path.join(os.path.dirname(__file__), "..", "documents", "jasmin_catering_prompt.md")
    with open(prompt_path, 'r', encoding='utf-8') as f:
        prompt = f.read()
    
    try:
        assistant = client.beta.assistants.create(
            name="Jasmin Catering Agent",
            instructions=prompt,
            model="gpt-4o",
            tools=[{"type": "file_search"}],
            description="Professional catering inquiry processor for Jasmin Catering Berlin",
            temperature=0.3
        )
        print(f"✅ Assistant created successfully!")
        print(f"   ID: {assistant.id}")
        print(f"   Name: {assistant.name}")
        print(f"   Model: {assistant.model}")
        return assistant
    except Exception as e:
        print(f"❌ Error creating assistant: {str(e)}")
        return None

def test_models():
    """Test which models are available"""
    print("\n🔍 Testing available models...")
    models_to_test = ["gpt-4o", "gpt-4", "gpt-35-turbo", "gpt-4-turbo"]
    
    for model in models_to_test:
        try:
            # Try a simple completion
            response = client.chat.completions.create(
                model=model,
                messages=[{"role": "user", "content": "Test"}],
                max_tokens=10
            )
            print(f"✅ {model} - Available")
        except Exception as e:
            print(f"❌ {model} - Not available: {str(e)}")

def main():
    print("🔍 Jasmin Catering Assistant Investigation")
    print("=========================================")
    
    # Check API key
    if not os.getenv("AZURE_AI_API_KEY"):
        print("❌ Error: AZURE_AI_API_KEY not found in environment")
        sys.exit(1)
    
    # Test models
    test_models()
    
    # List existing assistants
    assistants = list_assistants()
    
    # Check if our assistant exists
    target_id = "asst_MN5PHipyHYPXyq3fENx7V20j"
    found = any(a.id == target_id for a in assistants)
    
    if not found:
        print(f"\n⚠️ Assistant {target_id} not found on this endpoint.")
        print("\nOptions:")
        print("1. The assistant exists on a different Azure OpenAI resource")
        print("2. We need to create a new assistant")
        
        response = input("\nCreate a new assistant? (y/n): ")
        if response.lower() == 'y':
            assistant = create_assistant()
            if assistant:
                print(f"\n📝 Please update ASSISTANT_ID in your configuration to: {assistant.id}")
    else:
        print(f"\n✅ Assistant {target_id} found!")

if __name__ == "__main__":
    main()