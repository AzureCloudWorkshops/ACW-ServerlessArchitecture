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

param kvName string = 'WorkshopVault'

@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
@minLength(11)
@maxLength(11)
param yourUniqueDateString string = '20991231abc'

@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 7

var vaultName = '${kvName}${yourUniqueDateString}'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: vaultName
  location: location
  tags: {
    Environment: tagEnvironmentValue
  }
  properties: {
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    sku: {
      name: skuName
      family: 'A'
    }
    accessPolicies: []
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}
