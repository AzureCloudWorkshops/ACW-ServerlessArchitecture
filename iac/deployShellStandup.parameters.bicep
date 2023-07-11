@description('Provide a name for the resource group for all resources')
param resourceGroupName string = 'RG-ACWServerlessWorkshop20231231'

@description('Choose a region on your subscription where you can deploy the resources such as East US, West US, etc.')
param location string = 'eastus2'

@description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
@minLength(11)
@maxLength(11)
param yourUniqueDateAndInitialsString string = '20231231acw'
