#!/usr/bin/env python3
"""
Configure Assistant in Azure AI Foundry using REST API
This works with the AI Foundry project structure
"""

import os
import sys
import json
import requests
from pathlib import Path
from typing import List, Dict
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
ASSISTANT_ID = "asst_MN5PHipyHYPXyq3fENx7V20j"
DOCUMENTS_PATH = Path(__file__).parent.parent / "documents"
TEMPLATES_PATH = Path(__file__).parent.parent / "templates"

# Azure AI configuration
API_KEY = os.getenv("AZURE_AI_API_KEY")
AI_ENDPOINT = os.getenv("AZURE_AI_ENDPOINT", "https://jasmin-catering-resource.services.ai.azure.com/api/projects/jasmin-catering")

if not API_KEY:
    print("❌ Error: AZURE_AI_API_KEY not found in environment")
    sys.exit(1)

# Headers for API requests
headers = {
    "api-key": API_KEY,
    "Content-Type": "application/json"
}

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
                "name": filename
            })
    
    # Add template files
    for filename in template_files:
        filepath = TEMPLATES_PATH / filename
        if filepath.exists():
            documents.append({
                "path": str(filepath),
                "name": filename
            })
    
    return documents

def check_assistant_exists() -> bool:
    """Check if assistant exists in AI Foundry"""
    print(f"\n🔍 Checking assistant: {ASSISTANT_ID}")
    
    # Try different endpoint patterns
    endpoints_to_try = [
        f"{AI_ENDPOINT}/assistants/{ASSISTANT_ID}",
        f"{AI_ENDPOINT}/openai/assistants/{ASSISTANT_ID}",
        AI_ENDPOINT.replace("/api/projects/jasmin-catering", f"/openai/assistants/{ASSISTANT_ID}")
    ]
    
    for endpoint in endpoints_to_try:
        print(f"   Trying: {endpoint}")
        try:
            response = requests.get(endpoint, headers=headers)
            if response.status_code == 200:
                print(f"✅ Found assistant at: {endpoint}")
                data = response.json()
                print(f"   Name: {data.get('name', 'Unknown')}")
                return True
            else:
                print(f"   ❌ {response.status_code}: {response.text[:100]}")
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
    
    return False

def update_assistant_prompt(prompt: str) -> bool:
    """Update assistant instructions"""
    print(f"\n🤖 Updating assistant instructions...")
    
    # Try different endpoint patterns
    endpoints_to_try = [
        f"{AI_ENDPOINT}/assistants/{ASSISTANT_ID}",
        f"{AI_ENDPOINT}/openai/assistants/{ASSISTANT_ID}",
        AI_ENDPOINT.replace("/api/projects/jasmin-catering", f"/openai/assistants/{ASSISTANT_ID}")
    ]
    
    update_data = {
        "instructions": prompt,
        "name": "Jasmin Catering Agent",
        "description": "Professional catering inquiry processor for Jasmin Catering Berlin",
        "temperature": 0.3
    }
    
    for endpoint in endpoints_to_try:
        print(f"   Trying: {endpoint}")
        try:
            response = requests.patch(endpoint, headers=headers, json=update_data)
            if response.status_code == 200:
                print(f"✅ Assistant updated successfully!")
                return True
            else:
                print(f"   ❌ {response.status_code}: {response.text[:100]}")
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
    
    return False

def upload_documents() -> bool:
    """Upload documents to AI Foundry"""
    documents = get_documents_to_upload()
    print(f"\n📁 Found {len(documents)} documents to upload")
    
    # Note: Document upload to AI Foundry assistants may require specific API endpoints
    # This is a placeholder for the actual implementation
    print("\n⚠️ Document upload requires specific AI Foundry API endpoints")
    print("Documents prepared for upload:")
    for doc in documents:
        print(f"   - {doc['name']}")
    
    return True

def test_assistant() -> None:
    """Test the assistant with a sample query"""
    print(f"\n🧪 Testing assistant...")
    
    # Test endpoints
    test_endpoints = [
        f"{AI_ENDPOINT}/chat/completions",
        f"{AI_ENDPOINT}/openai/deployments/gpt-4o/chat/completions",
        AI_ENDPOINT.replace("/api/projects/jasmin-catering", "/openai/deployments/gpt-4o/chat/completions")
    ]
    
    test_data = {
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Test message"}
        ],
        "max_tokens": 50
    }
    
    for endpoint in test_endpoints:
        print(f"   Testing: {endpoint}")
        try:
            response = requests.post(endpoint, headers=headers, json=test_data)
            if response.status_code == 200:
                print(f"   ✅ Endpoint works!")
                return
            else:
                print(f"   ❌ {response.status_code}: {response.text[:100]}")
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")

def main():
    """Main execution"""
    print("🚀 Azure AI Foundry Assistant Configuration")
    print("==========================================")
    print(f"AI Endpoint: {AI_ENDPOINT}")
    print(f"Assistant ID: {ASSISTANT_ID}")
    print()
    
    # Read prompt
    prompt = read_prompt_file()
    
    # Check if assistant exists
    if not check_assistant_exists():
        print("\n❌ Assistant not found in AI Foundry")
        print("\nPossible reasons:")
        print("1. The assistant ID is incorrect")
        print("2. The assistant exists in a different project")
        print("3. Access permissions are missing")
        print("\n💡 Recommendation:")
        print("Use the Chat Completions API directly with the Logic App")
        print("Run: ./deployments/scripts/deploy-chat-completions.sh")
        return
    
    # Update assistant
    if update_assistant_prompt(prompt):
        print("\n✅ Assistant configuration updated!")
    else:
        print("\n❌ Failed to update assistant")
    
    # Upload documents
    upload_documents()
    
    # Test
    test_assistant()
    
    print("\n📊 Summary:")
    print(f"- Assistant ID: {ASSISTANT_ID}")
    print("- Prompt: Updated (if successful)")
    print("- Documents: Ready for upload")
    print("\n✨ Configuration process complete!")

if __name__ == "__main__":
    main()