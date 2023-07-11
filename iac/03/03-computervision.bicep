@description('note, you cannot do this until you have accepted the responsible AI agreement in the portal')
param dontusethis bool = true

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

// @description('That name is the name of our application. It has to be unique.Type a name followed by your resource group name. (<name>-<resourceGroupName>)')
// param cognitiveServiceName string = 'CognitiveService'

// @description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
// @minLength(11)
// @maxLength(11)
// param yourUniqueDateString string = '20991231abc'

// @description('Location for all resources.')
// param location string = resourceGroup().location

// @allowed([
//   'S0'
// ])
// param sku string = 'S0'

// var csVisionName = '${cognitiveServiceName}-${yourUniqueDateString}-${uniqueString(resourceGroup().id)}'

// resource cognitiveService 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
//   name: csVisionName
//   location: location
//   sku: {
//     name: sku
//   }
//   kind: 'CognitiveServices'
//   properties: {
//     apiProperties: {
//       statisticsEnabled: false
//     }
//   }
// }
