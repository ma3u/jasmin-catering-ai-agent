// Resources for Jasmin Catering AI Order Processing
param location string
param tags object
param logicAppName string
param storageAccountName string

@secure()
param aiApiKey string
param aiEndpoint string
param emailAlias string

@secure()
param emailPassword string

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Blob service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
}

// Storage container for email drafts
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  parent: blobService
  name: 'email-drafts'
  properties: {
    publicAccess: 'None'
  }
}

// Logic App
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: tags
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {}
          }
        }
      }
      actions: {
        Response: {
          runAfter: {}
          type: 'Response'
          inputs: {
            statusCode: 200
            body: {
              message: 'Jasmin Catering Order Processing deployed successfully'
              endpoint: aiEndpoint
              email: emailAlias
            }
          }
        }
      }
      outputs: {}
    }
  }
}

// Outputs
output logicAppId string = logicApp.id
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name