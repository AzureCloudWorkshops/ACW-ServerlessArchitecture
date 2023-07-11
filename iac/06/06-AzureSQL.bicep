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

@description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
@minLength(11)
@maxLength(11)
param yourUniqueDateString string = '20991231abc'

var sqlDBServerName = '${serverName}${yourUniqueDateString}'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlDBServerName
  location: location
  tags: {
    Environement: tagEnvironmentValue
  }
  properties: {
    administratorLogin: sqlServerAdminLogin
    administratorLoginPassword: sqlServerAdminPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: dbSKU
    capacity: dbCapacity
  }
  properties: {
    requestedBackupStorageRedundancy: 'local'
  }
}
