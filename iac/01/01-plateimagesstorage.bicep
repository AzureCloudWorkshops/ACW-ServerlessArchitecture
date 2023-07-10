@description('Storage account location')
param location string = resourceGroup().location
param environmentTag string = 'Workshop'

@minLength(3)
@maxLength(19)
@description('Provide a unique name for the storage account where you will load files. Use only lower case letters and numbers, at least 3 and <= 19 chars')
param storageName string = 'plateimages20991231'
var storageNameFormatted = substring('${storageName}xxxxxxxxxxxxxxxx', 0, 19)
var storageAccountName = substring('${storageNameFormatted}${uniqueString(resourceGroup().id)}', 0, 24)

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
param storageSku string = 'Standard_LRS'

@description('Allow blob public access')
param allowBlobPublicAccess bool = true

@description('Allow shared key access')
param allowSharedKeyAccess bool = true

@description('Storage account access tier, Hot for frequently accessed data or Cool for infreqently accessed data')
@allowed([
  'Hot'
  'Cool'
])
param storageTier string = 'Hot'

@description('Enable blob encryption at rest')
param blobEncryptionEnabled bool = true

@description('Enable Blob Retention')
param enableBlobRetention bool = false

@description('Number of days to retain blobs')
param blobRetentionDays int = 7

@description('The name of the container in which to upload images')
param imagesContainer string = 'images'

@description('The storage account.  Toggle the public access to false if you do not want public blobs on the account in any containers')
resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku
  }
  tags: {
    Environment: environmentTag
  }
  properties: {
    allowBlobPublicAccess: allowBlobPublicAccess
    accessTier: storageTier
    allowSharedKeyAccess: allowSharedKeyAccess
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: blobEncryptionEnabled
        }
      }
    }
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageaccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: enableBlobRetention
      days: blobRetentionDays
    }
  }
}

// Create the images container
resource images 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: imagesContainer
  parent: blobServices
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    metadata: {}
    publicAccess: allowBlobPublicAccess ? 'Blob' : 'None'
  }
}
