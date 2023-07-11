@description('Location for all resources.')
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

@description('Name of the Service Bus namespace')
param sbNamespace string = 'licenseplateprocessing'

@description('Name of the Queue')
param serviceBusQueueName string = 'unprocessedplates'



@description('Service Bus Tier [Basic, Standard, Premium]. Use Basic unless you need pub/sub topics.')
@allowed([
  'Basic'
])
param serviceBusSku string = 'Basic'

@description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
@minLength(11)
@maxLength(11)
param yourUniqueDateString string = '20991231abc'

var serviceBussNamespaceName = '${sbNamespace}${yourUniqueDateString}'

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBussNamespaceName
  location: location
  tags: {
    Environment: tagEnvironmentValue
  }
  sku: {
    name: serviceBusSku
  }
  properties: {}
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: serviceBusQueueName
  properties: {
    lockDuration: 'PT5M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'PT4H'
    deadLetteringOnMessageExpiration: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    enablePartitioning: false
    enableExpress: false
  }
}

resource queueManager 'Microsoft.ServiceBus/namespaces/queues/AuthorizationRules@2022-10-01-preview' = {
  name: 'Admin'
  parent: serviceBusQueue
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
  }
}

resource queueProducer 'Microsoft.ServiceBus/namespaces/queues/AuthorizationRules@2022-10-01-preview' = {
  name: 'Producer'
  parent: serviceBusQueue
  properties: {
    rights: [
      'Send'
    ]
  }
}
resource queueConsumer 'Microsoft.ServiceBus/namespaces/queues/AuthorizationRules@2022-10-01-preview' = {
  name: 'Consumer'
  parent: serviceBusQueue
  properties: {
    rights: [
      'Listen'
    ]
  }
}
