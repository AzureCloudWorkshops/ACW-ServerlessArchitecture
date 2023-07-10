param resourceGroupName string = 'RG-ACWServerlessArchitecture'
param location string = 'westus3'

@allowed([
  'Dev'
  'Test'
  'Prod'
  'Workshop'
  'POC'
  'Temp'
])
param tagEnvironmentValue string = 'Workshop'

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: tagEnvironmentValue
  }
  properties: {}
}

output rg object = resourceGroup
