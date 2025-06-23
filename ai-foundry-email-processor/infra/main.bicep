// Bicep template for Jasmin Catering AI Order Processing
targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@secure()
@description('Azure AI API Key from .env')
param aiApiKey string

@secure()
@description('Web.de app password from .env')
param emailPassword string

@description('Web.de email alias')
param emailAlias string

@description('Azure AI endpoint')
param aiEndpoint string

// Tags
var tags = {
  azdEnvName: environmentName
  project: 'jasmin-catering'
  purpose: 'order-processing'
}

// Resource names
var resourceGroupName = 'rg-${environmentName}'
var logicAppName = 'logic-${environmentName}-order-processor'
var storageAccountName = 'st${replace(environmentName, '-', '')}${uniqueString(resourceGroup.id)}'

// Create resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Create resources in the resource group
module resources 'resources.bicep' = {
  name: 'resources'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    logicAppName: logicAppName
    storageAccountName: storageAccountName
    aiApiKey: aiApiKey
    aiEndpoint: aiEndpoint
    emailAlias: emailAlias
    emailPassword: emailPassword
  }
}

output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = resourceGroup.name
output LOGIC_APP_NAME string = logicAppName
output STORAGE_ACCOUNT_NAME string = storageAccountName