param resourceGroupName string = 'RG-ACWServerlessArchitecture'

@description('Resource Location - choose a valid Azure region for your deployment')
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

param blobEncryptionEnabled bool = true

@description('Enable Blob Retention')
param enableBlobRetention bool = false

@description('Number of days to retain blobs')
param blobRetentionDays int = 7

@minLength(3)
@maxLength(19)
@description('Provide a unique name for the storage account where you will load files. Use only lower case letters and numbers, at least 3 and <= 19 chars')
param imagesStorageName string = 'plateimages20991231'

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
param imagesStorageSku string = 'Standard_LRS'

@description('Allow blob public access')
param allowImageBlobPublicAccess bool = true

@description('Allow shared key access')
param allowImageStorageSharedKeyAccess bool = true

@description('Storage account access tier, Hot for frequently accessed data or Cool for infreqently accessed data')
@allowed([
  'Hot'
  'Cool'
])
param imagesStorageTier string = 'Hot'

@description('The name of the container in which to upload images')
param imagesContainerName string = 'images'

@description('The name of the container for exports')
param exportsContainerName string = 'exports'

@minLength(3)
@maxLength(21)
@description('Provide a unique name for the storage account where you will load files. Use only lower case letters and numbers, at least 3 and <= 21 chars')
param exportsStorageName string = 'datalakexprts20991231'

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
param exportsStorageSKU string = 'Standard_LRS'

@description('Allow blob public access')
param allowExportBlobPublicAccess bool = true

@description('Allow shared key access')
param allowExportSharedKeyAccess bool = true

@description('Storage account access tier, Hot for frequently accessed data or Cool for infreqently accessed data')
@allowed([
  'Hot'
  'Cool'
])
param exportsStorageTier string = 'Hot'

@description('Enable hierarchical namespace for data lake')
param enableExportsHierarchicalNamespace bool = true


targetScope = 'subscription'

resource serverlessRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: tagEnvironmentValue
  }
  properties: {}
}

module plateImagesStorageAccountAndImagesContainer '01-plateimagesstorage.bicep' = {
  name: 'plateImagesStorageAccount'
  scope: serverlessRG
  params: {
    location: location
    storageName: imagesStorageName
    allowBlobPublicAccess: allowImageBlobPublicAccess
    allowSharedKeyAccess: allowImageStorageSharedKeyAccess
    storageSku: imagesStorageSku
    storageTier: imagesStorageTier
    blobEncryptionEnabled: blobEncryptionEnabled
    enableBlobRetention: enableBlobRetention
    blobRetentionDays: blobRetentionDays
    environmentTag: tagEnvironmentValue
    imagesContainer: imagesContainerName
  }
}

module datalakeExportsStorageAccountAndExportsContainer '01-datalakeexports.bicep' = {
  name: 'datalakeExportsStorageAccount'
  scope: serverlessRG
  params: {
    location: location
    storageName: exportsStorageName
    allowBlobPublicAccess: allowExportBlobPublicAccess
    allowSharedKeyAccess: allowExportSharedKeyAccess
    storageSku: exportsStorageSKU
    storageTier: exportsStorageTier
    blobEncryptionEnabled: blobEncryptionEnabled
    enableHierarchicalNamespace: enableExportsHierarchicalNamespace
    environmentTag: tagEnvironmentValue
    exportsContainer: exportsContainerName
  }
}
