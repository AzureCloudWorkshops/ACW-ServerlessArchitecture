@description('Resource Location - choose a valid Azure region for your deployment')
param location string = resourceGroup().location

@allowed([
  'Dev'
  'Test'
  'Prod'
  'Workshop'
  'POC'
  'Temp'
])
param tagEnvironmentValue string = 'Workshop'

@minLength(16)
@maxLength(21)
@description('Provide a name for the storage account to back the function app. Use only lower case letters and numbers, at least 3 and less than 17 chars')
param fnStorageName string = 'imageprocessingfnstor'

@description('Storage account sku')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param fnStorageSKU string = 'Standard_LRS'

var fnStorageAccountName = substring('${fnStorageName}${uniqueString(resourceGroup().id)}', 0, 24)

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'dotnet-isolated'
  'java'
])
param runtime string = 'dotnet'

@description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
@minLength(11)
@maxLength(11)
param yourUniqueDateString string = '20991231abc'

@description('The name of the function app that you wish to create.')
@minLength(14)
@maxLength(22)
param functionAppName string = 'LicensePlateProcessing'

@description('The SKU/Name of the hosting plan that you wish to create.')
@allowed([
  'Y1'
])
param functionAppHostingPlan string = 'Y1'

var fnAppName = substring('${functionAppName}${yourUniqueDateString}${uniqueString(resourceGroup().id)}', 0, 33)
var hostingPlanName = 'ASP-${fnAppName}'
var applicationInsightsName = 'AI-${fnAppName}'
var functionWorkerRuntime = runtime

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: fnStorageAccountName
  location: location
  sku: {
    name: fnStorageSKU
  }
  tags: {
    Environment: tagEnvironmentValue
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: functionAppHostingPlan
  }
  tags: {
    Environment: tagEnvironmentValue
  }
  properties: {}
}

//note: in production consider backing app insights with a dedicated log analytics workspace
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  tags: {
    Environment: tagEnvironmentValue
  }
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: fnAppName
  location: location
  kind: 'functionapp'
  tags: {
    Environment: tagEnvironmentValue
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${fnStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${fnStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(fnAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'computerVisionKey'
          value: 'tbd'
        }
        {
          name: 'computerVisionUrl'
          value: 'tbd'
        }
        {
          name: 'cosmosDBAuthorizationKey'
          value: 'tbd'
        }
        {
          name: 'cosmosDBContainerId'
          value: 'Processed'
        }
        {
          name: 'cosmosDBDatabaseId'
          value: 'LicensePlates'
        }
        {
          name: 'cosmosDbEndpointUrl'
          value: 'tbd'
        }
        {
          name: 'datalakeexportscontainer'
          value: 'exports'
        }
        {
          name: 'eventGridTopicEndpoint'
          value: 'tbd'
        }
        {
          name: 'eventGridTopicKey'
          value: 'tbd'
        }
        {
          name: 'plateImagesStorageConnection'
          value: 'tbd'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
