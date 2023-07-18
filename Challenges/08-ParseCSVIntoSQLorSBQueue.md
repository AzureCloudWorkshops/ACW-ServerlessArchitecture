# Azure Cloud Workshops - Serverless Architecture - Challenge 08 - Export Parsing

In this challenge you will parse the exported CSV files based on data received from the previous challenge. Based on the name of the file the correct function will have been triggered.

The function will review the body of the post to get the correct file from storage, will parse the CSV file, and will put the processed data into the legacy SQL ticketing system.  

## Task 1 - Build the Storage Connection and File Parsing common logic  

For this task you will push all of the confirmed records into a simple table that stores the same information that was in the CSV File.  For our purposes, this is the final step to get data into the legacy system.  In the real world, you might also have to do things like look up the registration information and add that foreign key to the record.  

There are many ways you could go about getting the data into the database.  You could create a WebAPI and authorize a post to the endpoint with the records.  You could build an Azure Data Factory pipeline that moves the data from cosmos to SQL.  You could have someone manually review the file and enter it.  You could use an on-premises SSIS package with the file. As such, the solution here is but one option in a choice of many, and may not represent the best solution.

For this solution, however, you will just leverage the database library project and push directly to the application database that you created in the first task above.

In the previous challenge you already created the functions, now you just need to complete the work for the functions.

Both paths will utilize the same code to parse the incoming file.  The first task will be to be able to connect to the storage account via the key and be able to then get the appropriate file and then parse the file using the CSV parsing code.

The output will be a list of LicensePlates.  The application will then need to utilize the database library from the legacy system to push the list into the database.

The two paths are: 
- Process Reviewed/Ready for Import plates to the SQL Database
- Process Non-Reviewed/Ready for Review plates to Azure Service Bus

1. Get the files from storage
1. Parse the CSV file to get plate data into an object

## Task 2 - Process Confirmed Records to Azure SQL

Now that the processing function is ready to go, it's time to move the data.  For the Imports, there are two actions to complete.  

First, data for the plate needs to be entered to Azure SQL and second Cosmos needs to be updated, setting each record that was imported as finalized (completed and exported set to true).  This will finalize the plate and prevent any further exporting or evaluation of these plates.  

1. Bring in the `shared` libraries for data access
1. For non isolated functions, add the dependency injection for the entity framework integration
1. Ensure you have the connection strings leveraged correctly from KeyVault for the two database connections
1. Add the logic to save the data to the database
1. Review the database table and/or review the plates page on the web admin system

## Task 3 - Process Unconfirmed Records to Service Bus

For this task, you will push all of the records that are ready for review into the Azure Service Bus Queue so that the team can perform the required manual review on those plates to validate the results.  

1. Create the producer (writemessages) SAS token on the Service Bus Queue
1. Add the SAS Token to the KeyVault
1. Leverage the SAS Token and queue name as variables in the Function App Configuration settings
1. Write the code to push reviews to Service Bus
1. Review your service bus has the new messages for plates to review

## Conclusion

In this challenge you modified the two functions that were being used for processing files to either push import data to the SQL Server or push information about files that need to be reviewed into the service bus queue. 
