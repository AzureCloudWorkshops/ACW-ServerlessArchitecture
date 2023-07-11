@description('Provide a name for the resource group for all resources')
param resourceGroupName string

@description('Choose a region on your subscription where you can deploy the resources such as East US, West US, etc.')
param location string

@description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
@minLength(11)
@maxLength(11)
param yourUniqueDateAndInitialsString string

@allowed([
  'Dev'
  'Test'
  'Prod'
  'Workshop'
  'POC'
  'Temp'
])
param tagEnvironmentValue string = 'Workshop'

//01 parameters follow: ***********************************************************************************
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

//02 parameters follow: ***********************************************************************************
@minLength(16)
@maxLength(21)
@description('Provide a name for the storage account to back the function app. Use only lower case letters and numbers, at least 3 and less than 17 chars')
param imageProcesingFunctionStorageName string = 'imageprocessingfnstor'

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
param imageProcessingFunctionStorageSKU string = 'Standard_LRS'

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'dotnet-isolated'
  'java'
])
param plateImageProcessingFunctionsRuntime string = 'dotnet'

@description('The name of the function app that you wish to create.')
@minLength(14)
@maxLength(22)
param plateProcessingFunctionAppName string = 'LicensePlateProcessing'

@description('The SKU/Name of the hosting plan that you wish to create.')
@allowed([
  'Y1'
])
param plateImageProcessingHostingPlanSKU string = 'Y1'

param kvName string = 'WorkshopVault'

@allowed([
  'standard'
  'premium'
])
param kvSkuName string = 'standard'

@minValue(7)
@maxValue(90)
param keyVaultSoftDeleteRetentionInDays int = 7

//04 parameters follow: ***********************************************************************************

@minLength(16)
@maxLength(21)
@description('Provide a name for the storage account to back the function app. Use only lower case letters and numbers, at least 3 and less than 17 chars')
param eventHandlerFunctionStorageName string = 'lpeventhndlerfuncstor'

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
param eventHandlerFunctionStorageSKU string = 'Standard_LRS'

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
])
param eventHandlerFunctionRuntime string = 'node'

@description('The name of the function app that you wish to create.')
@minLength(25)
@maxLength(33)
param eventHandlerFunctionAppName string = 'LicensePlateEventHandlerFunctions'

@description('The SKU/Name of the hosting plan that you wish to create.')
@allowed([
  'Y1'
])
param eventHandlerFunctionAppHostingPlan string = 'Y1'

@description('Name of the Service Bus namespace')
param sbNamespace string = 'licenseplateprocessing'

@description('Name of the Queue')
param serviceBusQueueName string = 'unprocessedplates'

@description('Service Bus Tier [Basic, Standard, Premium]. Use Basic unless you need pub/sub topics.')
@allowed([
  'Basic'
])
param serviceBusSku string = 'Basic'

//07 parameters follow: ***********************************************************************************

@description('Name of the SQL Db Server')
param serverName string = 'licenseplatedbserver'

@description('Name of the Sql Database')
param sqlDatabaseName string = 'LicensePlateDataDb'

@description('Admin UserName for the SQL Server')
param sqlServerAdminLogin string = 'serverlessuser'

@description('Admin Password for the SQL Server')
@secure()
param sqlServerAdminPassword string = 'workshopDB#54321!'

@description('Service Bus Tier [Basic, Standard, Premium]. Use Basic unless you need pub/sub topics.')
@allowed([
  'Basic'
])
param dbSKU string = 'Basic'

@description('The number of DTUs for a DTU-Based SQL Server')
param dbCapacity int = 5

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

@description('The language worker runtime to load in the web app.')
@allowed([
  'node'
  'dotnet'
  'dotnet-isolated'
  'java'
])
param workerRuntime string = 'dotnet'

//deployments follow: ***********************************************************************************
targetScope = 'subscription'

resource serverlessRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: tagEnvironmentValue
  }
  properties: {}
}

module plateImagesStorageAccountAndImagesContainer '01/01-plateimagesstorage.bicep' = {
  name: 'Plate_Images_Blob_Storage_Account'
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

module datalakeExportsStorageAccountAndExportsContainer '01/01-datalakeexports.bicep' = {
  name: 'Data_Lake_Exports_Storage'
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

module plateImageProcessingFunctionApp '02/02-imageprocessingfnapp.bicep' = {
  name: 'Image_Processing_Function_App'
  scope: serverlessRG
  params: {
    location: location
    fnStorageName: imageProcesingFunctionStorageName
    fnStorageSKU: imageProcessingFunctionStorageSKU
    runtime: plateImageProcessingFunctionsRuntime
    functionAppName: plateProcessingFunctionAppName
    functionAppHostingPlan: plateImageProcessingHostingPlanSKU
    tagEnvironmentValue: tagEnvironmentValue
    yourUniqueDateString: yourUniqueDateAndInitialsString
  }
}

module keyVault '02/02-keyvault.bicep' = {
  name: 'Workshop_Key_Vault'
  scope: serverlessRG
  params: {
    location: location
    kvName: kvName
    skuName: kvSkuName
    softDeleteRetentionInDays: keyVaultSoftDeleteRetentionInDays
    tagEnvironmentValue: tagEnvironmentValue
    yourUniqueDateString: yourUniqueDateAndInitialsString
  }
}

module eventHandlingFunctionApp '04/04-eventhandlingfnapp.bicep' = {
  name: 'Event_Handling_Function_App'
  scope: serverlessRG
  params: {
    location: location
    fnStorageName: eventHandlerFunctionStorageName
    fnStorageSKU: eventHandlerFunctionStorageSKU
    runtime: eventHandlerFunctionRuntime
    functionAppName: eventHandlerFunctionAppName
    functionAppHostingPlan: eventHandlerFunctionAppHostingPlan
    tagEnvironmentValue: tagEnvironmentValue
    yourUniqueDateString: yourUniqueDateAndInitialsString
  }
}

module serviceBusWithQueue '04/04-servicebus.bicep' = {
  name: 'Service_Bus_with_Queue'
  scope: serverlessRG
  params: {
    location: location
    sbNamespace: sbNamespace
    serviceBusQueueName: serviceBusQueueName
    serviceBusSku: serviceBusSku
    tagEnvironmentValue: tagEnvironmentValue
    yourUniqueDateString: yourUniqueDateAndInitialsString
  }
}

module legacyAdminDatabase '07/07-AzureSQL.bicep' = {
  name: 'Sql_Server'
  scope: serverlessRG
  params: {
    location: location
    tagEnvironmentValue: tagEnvironmentValue
    yourUniqueDateString: yourUniqueDateAndInitialsString
    serverName: serverName
    dbCapacity: dbCapacity
    dbSKU: dbSKU
    sqlDatabaseName: sqlDatabaseName
    sqlServerAdminLogin: sqlServerAdminLogin
    sqlServerAdminPassword: sqlServerAdminPassword
  }
}

module adminWebApp '07/07-WEBAPP.bicep' = {
  name: 'Admin_Web_App'
  scope: serverlessRG
  params: {
    location: location
    tagEnvironmentValue: tagEnvironmentValue
    yourUniqueDateString: yourUniqueDateAndInitialsString
    appName: appName
    webAppHostingPlan: webAppHostingPlan
    workerRuntime: workerRuntime
  }
}
