# Azure Cloud Workshops - Serverless Architecture - Challenge 04 - Processing Events

In this challenge you will write code to process the event from storage and integrate with the results from ComputerVision to get the file information into Cosmos DB for the first round of exporting.

This part of the project is heavy with code so you may choose to reference some of the walkthrough or the sample code in order to get some clarity if you are uncertain as to the direction or next steps required.

At the end of the challenge you will also need to create an Azure Service Bus Queue where you will pass information for failed reads to request further human intervention.  

## Step 1 - Examine the event payload and create a model for the payload

In this step you will examine the payload of an event from storage to the Azure function to get the data schema. You will then use that schema to build a class to model the data from the event.  You will then put that code into your Azure Function app.

1. Review the payload from an event using the Monitor 
    - Open the Function in the portal
    - Get the data information from the Invocation Details on a sucessful run
    - Add a new folder `EventLogic` in the Azure Function App
    - Use the message information to build a class (convert JSON to C#) `EventDataInfo` with a `StorageDiagnostics` class that has the `batchId` property
        - Ensure you have the `url` field in the EventDataInfo
    - Utilize the new data info in the ProcessImage function to get the raw data into an object using JSON Deserialization
    - limit results that you want to process further to `image/jpeg` or `image/png` by using a simple `if` condition on the event content type
    - write output to prove the object is deserialized correctly using the logger
    - test the function by triggering it using a new file upload to storage and making sure you see the event data url as captured correctly in your object

## Step 2 - Trigger an event from the vision result

In this step, you will create two paths using event grid events for processing results from the computer vision. One path for good reads, which will publish to CosmosDB using function bindings, and another path to Service Bus for reads that were uncertain and require human intervention

1. Create a new Library Project called `LicensePlateDataModels`
1. Create a class `LicensePlatData.cs`
    - Add properties for FileName, LicensePlateText, TimeStamp, LicensePlateFound, and NeesReview
1. Add a project reference in the Function App to the new library
1. Create a new class in the EventLogic section to model an Event
1. Create a new class in the EventLogic section called `TriggerEvent`, which will publish an event to the event grid for each result
    - utilize `savePlateData` for the good path
    - utilize `reviewPlateData` for the bad path
1. Update the process image function with the code to trigger an event

## Step 3 - Create a Cosmos DB Account

For this step, you need to provision a CosmosDB account named `licenseplatedataYYYYMMDDxyz` with a database named 

1. Provision a CosmosDB account on either the free tier or with a minimal amount of RUs provisioned.  Do not use the serverless CosmosDB.

## Step 4 - Create the Custom Events Response Function

For the event response functions, you'll create these in the portal.  The code stack is node (javascript).  You will need to make two functions (happy/sad paths). Happy path will write to Cosmos DB, Sad path will write to Azure Service Bus

1. Create the function app in the portal named something like `LicensePlateEventHandlerFunctionsYYYYMMDDxyz`
1. Use node

## Step 5 - Create the Cosmos DB and Container

Create a database and container for storing information

1. Create a database named `LicensePlates`
1. Create a container in the database named `Processed`
    - Use minimal RUs (i.e. 400)
    - Set a partition key of `/fileName`
1. Get the Endpoint and the Read/Write Key and save them for use later

## Step 6 - Create the "happy path success" function

Create a new function to respond to good reads

1. In the portal function app, add a new function with an EventGridTrigger named `SavePlateData`
1. Write the code to output the document using the bindings

## Step 7 - Create an integration output binding subsubscription to Cosmos DB

1. Create a new EventGridSubscription on the EventGridTrigger `SavePlateDataSub`
    - Use the event grid schema
    - Select your topic that already exists
    - Bind to event type `savePlateData`
1. Use the integrations to output the document to cosmos db
    - Select your account and make a new connection
1. Test that good plate reads make it to Cosmos DB (requires that your function app is triggering the event and passing to the `savePlateData` event type)

## Step 8 - Create a Service Bus Queue

Create a Basic Service Bus Queue for storing messages that need human intervention

1. Create the service Bus Queue in the Basic tier (you don't need Topics for this)
    - named: `licenseplateprocessingYYYYMMDDxyz`
1. Create the queue
    - named: `UnprocessedPlates`
    - shared access policies: 
        - writeMessages `Send` permission
        - readMessages `Listen` permission
    - get the primary connection string

## Step 9 - Write failed messages to the Service Bus Queue

1. Create the function in the portal `QueuePlateDataForReview`
1. Add the code to process the event 
1. Add the Event Grid Trigger inbound integration
1. Add the output integration to write a message to service bus
1. Test that bad plates add a message to the Service Bus Queue

## Conclusion

This is a very long challenge but gets your solution wired up to utilize a function app with bindings to write good data to cosmos and bad data to service bus for processing using a custom event triggered by the Azure Function on the result of the vision processing
