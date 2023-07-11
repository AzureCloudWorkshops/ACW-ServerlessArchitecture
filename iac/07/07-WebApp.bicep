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

@description('The language worker runtime to load in the web app.')
@allowed([
  'node'
  'dotnet'
  'dotnet-isolated'
  'java'
])
param workerRuntime string = 'dotnet'

@description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
@minLength(11)
@maxLength(11)
param yourUniqueDateString string = '20991231abc'

@description('The name of the web app that you wish to create.')
@minLength(20)
@maxLength(20)
param appName string = 'LicensePlateAdminWeb'

@description('The SKU/Name of the hosting plan that you wish to create.')
@allowed([
  'B1'
  'F1'
  'S1'
])
param webAppHostingPlan string = 'F1'

var webAppName = substring('${appName}${yourUniqueDateString}', 0, 31)
var hostingPlanName = 'ASP-${appName}'
var logAnalyticsName = 'LA-${appName}'
var applicationInsightsName = 'AI-${appName}'


resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: webAppHostingPlan
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  tags: {
    Environment: tagEnvironmentValue
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
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
          name: 'plateImagesStorageConnection'
          value: 'tbd'
        }
        {
          name: 'plateimagesstoragecontainer'
          value: 'images'
        }
        {
          name: 'PlateImagesSASToken'
          value: 'TBD'
        }
        {
          name: 'ServiceBusQueueName'
          value: 'unprocessedplates'
        }
        {
          name: 'ReadOnlySBConnectionString'
          value: 'tbd'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
