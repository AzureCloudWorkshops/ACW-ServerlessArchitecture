# Azure Cloud Workshops - Serverless Architecture - Challenge 07 - Export Parsing

In this challenge you will create the Azure SQL Database and the Web Administration system. You will wire up the web solution and make sure everything works with the Azure Database.

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
1. Utilize the starter code provided with this repository under teh `SourceFiles` directory
1. Publish your web app to Azure (or use CI/CD)
1. Reference both SQL Server Connection strings to map to your SQL Database (it is ok to share the db)
1. Ensure the web app can connect to your Azure SQL database (the database will auto-migrate if you use the sample app)
1. Ensure the web application works as expected and that you can navigate to the `Review Plates` page and see the ten seeded plates

## Conclusion

In this step you created the Azure SQL and the Azure App Service to host the legacy application. 