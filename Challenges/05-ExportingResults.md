# Azure Cloud Workshops - Serverless Architecture - Challenge 05 - Exporting Results

In this challenge, you will create a function that runs on a schedule. The purpose of this function is to export any processed and confirmed plate information for import into the tickets database.

Since there have been a number of false positives, another export for unconfirmed records has been requested, and all data from those records needs to be queued for manual review.

Interested parties are concerned about the number of false positives and errors in the vision system and want a direct report when a new batch of unconfirmed but processed data is exported.

Therefore, your goal for this step is to create two export files, one for completed files and one for processed but unconfirmed.

To make it easier for downstream processing, completed files shall be named YYYYMMDDHHMMSS_####_PlatesReadyForImport.csv and files with processed but unconfirmed data will be named YYYYMMDDHHMMSS_####_PlatesProcessedButUnconfirmed.csv. The #### will be the number of records in the file, and the YYYYMMDDHHMMSS is just a timestamp for the file exports.

## Task 1 - Create the schedule triggered function

To get started, you will add another function to the LicensePlateProcessing function app. In this task, you will create this function on a schedule to poll cosmos db and get all the records marked as unconfirmed and unexported.

1. Create a new timer-triggered function named `ExportPlateData` in the `LicensePlateProcessing` function app
1. Set the function to be asynchronous and use a reasonable CRON job interval

## Task 2 - Interaction with Cosmos DB

In order for this project to work, you'll need to interact with Cosmos DB. In this task you'll set the code that allows querying and working with Cosmos data from .Net.

1. Add logic for processing from Cosmos using .NET in a folder called `CosmosLogic` with a class named `CosmosOperations` in the `LicensePlateProcessing` app
1. Add a class to model the `LicensePlateDataDocument`
1. Use a 2-bit system to move the files from not exported, not reviewed to exported, not reviewed to reviewed not exported to exported and reviewed so each entry can be exported for review, reviewed, then exported for completed.
1. Create a method to get the plates for export (whether reviewed or not)
1. Create a method to mark the plates as exported
1. Create a CSV in memory from the data in a folder called `StorageAndFileProcessing` and a class called `CreateCSVFromPlateDataInMemory`

## Task 3 - Storage Interaction

In this task, you will create code to interact with Azure Storage for read/write of the export csv files.

1. Create a class for storage in the `StorageAndFileProcessing` folder called `BlobStorageHelper` which will use the `Azure.Storage.Blobs` NuGet package
1. Add methods for upload and download files as byte[] to and from storage using the SDK.

## Task 4 - Query cosmos to get the data for the two exports, generate files, export to storage, and mark the data as exported

In this task you'll modify the `ExportPlateData` function to create the two exports using the helpers created above.

1. Use code to get connected to Cosmos DB (make sure to include four configuration variables for the cosmosdb, and two for storage)
    - cosmosDBEndpointUrl;
    - cosmosDBAuthorizationKey
    - cosmosDBDatabaseId
    - cosmosDBContainerId
    - datalakeexportscontainer
    - datalakeexportsconnection
1. The code needs to get the plates for export, separate by reviewed or not, and create a CSV for each of the confirmed or non confirmed (for review) paths.  
1. The code should also mark each plate data retrieved as exported in cosmos.
1. The end result is one or two (if confirmed records that are not exported exist) CSV files, one with plates for review (export false / reviewed false) and one with confirmed plates (exported false / reviewed true), exported into Blob Storage for later retrieval
1. After the execution, no plates should be in the `export false` state until new plate data comes in from computer vision.

## Task 5 - Update the cosmos and storage information in the function app

Before deploying, you will want to make sure that the variables for cosmos and your storage account are set correctly in the Azure Function App Configuration.

For this application to work, you will need to add six application configuration settings (if you didn't add any of them previously). They are all leveraged in the `ExportPlateData` function call, but specifically, they are:

1. Set the Cosmos Key and the data lake exports connection in KeyVault, the rest can be set directly on the function app configuration


| ApplicationSetting | Expected Value |
|--|--|
| cosmosDBEndpointUrl | The endpoint for your cosmos db instance |
| cosmosDBAuthorizationKey | The Key for your cosmos db instance (from keyvault) |
| cosmosDBDatabaseId | The name of your cosmos db (likely named `LicensePlates`) |
| cosmosDBContainerId | The name of the container (likely named `Processed`) |  
| datalakeexportsconnection | The connection string to your datalake storage account set to a Keyvault URI. The account was created in Challenge 1 as `datalakeexports` (not the images storage account) |  
| datalakeexportscontainer | The name of the container for exports from the `datalakeexports` account(likely named `exports`)  

## Task 6 - Deploy the function app

Check in changes to deploy

1. Wait for deployment
1. Validate no errors on the timer trigger
1. Validate cosmos interaction is happening as expected for the first part (export)
1. Validate that the export csv is in the storage account

## Conclusion

In this challenge you created the logic to interact with cosmos db and azure storage using code from the .NET SDKs. You created an export file based on a query from cosmos for the images that have been analyzed by vision and set them to exported for the first review.  You exported the CSV of exported plates for review to the storage account.
