# Azure Cloud Workshops - Serverless Architecture - Challenge 07 - Export Parsing

In this challenge you will parse the exported CSV files based on data received from the previous challenge. Based on the name of the file the correct function will have been triggered.

The function will review the body of the post to get the correct file from storage, will parse the CSV file, and will put the processed data into the legacy SQL ticketing system.  

## Task 1 - Create the Simulated legacy database

For part of this solution, you will port data into an Azure SQL database to simulate the legacy ticketing system. Once license plates are verified, you will push the data into this system. In this first task you will create the "legacy" database as a basic SQL Database at Azure.

1. Create an Azure SQL Database
1. Ensure Networking allows Azure Services and your IP
1. Add database connection string information into KeyVault
1. Get the Starter Project or create your own Admin System to interact with the database from an Azure App Service
1. Create a new repository and push the code for the starter project to it

## Task 2 - Deploy a new Azure web App

For this next task, you will deploy the web application in order to also provision the database.  Although it's likely not the best practice, the web application code is provisioned in a way that will automatically run migrations when the app is started.  

Without the database set up correctly, this will cause the application to break until the database connection strings are correctly wired up and migrations are applied. 

Another side-effect of this approach is the fact that the migrations will only be able to roll forward, as building to target a migration will automatically apply any migrations, so you won't ever be able to remove a migration once it has been created.  

These "gotchas" will not affect our project as we likely don't need any database changes or migration work, and having the automatic application would make any future changes easier.

1. Create the new Web App named something like `ASP-RGServerlessWorkshopYYYYMMDDxyz`  
1. Publish your web app to Azure (or use CI/CD)
1. Ensure the web app can connect to your Azure SQL database (the database will auto-migrate if you use the sample app)

Task 3 - Build the Storage Connection and File Parsing common logic

For this task you will push all of the confirmed records into a simple table that stores the same information that was in the CSV File. For our purposes, this is the final step to get data into the legacy system. In the real world, you might also have to do things like look up the registration information and add that foreign key to the record.

There are many ways you could go about getting the data into the database. You could create a WebAPI and authorize a post to the endpoint with the records. You could build an Azure Data Factory pipeline that moves the data from cosmos to SQL. You could have someone manually review the file and enter it. You could use an on premises SSIS package with the file.

For this solution, you will just leverage the database library project and push directly to the application database that you created in the first task above.

In the previous challenge you already created the functions, now you just need to complete them.

Both paths will utilize the same code to parse the incoming file. The task will be to be able to connect to the storage account via the key and be able to then get the file and then parse the file using the CSV parsing code.

The output will be a list of LicensePlates. The application will then need to utilize the database library from the legacy system to push the list into the database.

1. Modify the `ProcessImports` function to get the file from storage
1. Modify the function to get the plate data from the CSV

## Task 4 - Process Confirmed Records to Azure SQL

Now that the processing function is ready to go, it's time to move the data. For the Imports, there are two actions to complete.

First, you need to get the data into SQL and second you need to update Cosmos, setting each record that was imported as finalized (completed and exported set to true). This will prevent any further exporting or evaluation of these plates.

1. Modify the Database Library in the legacy app
1. Update the two database connection strings in the function app
1. 

## Task 5 - Process Unconfirmed Records to Service Bus

For this task, you will push all of the records that are ready for review into the Azure Service Bus Queue so that the team can perform the required manual review on them to validate the results.

If time permits, consider also putting this into a feature flag toggle, where you can easily turn it off once the team is satisfied that the vision system is processing as expected. In that case, you would still want to

