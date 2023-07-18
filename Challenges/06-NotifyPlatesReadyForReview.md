# Azure Cloud Workshops - Serverless Architecture - Challenge 06 - Handling Data and Sending Notifications

In this challenge you will use a logic app to respond to storage events. On the storage event, you will respond to the file based on the naming convention previously established.

After parsing the file name, you will send an email to the interested parties with the number of records that were marked as processed but not confirmed, and therefore pushed into Cosmos as supposedly correct.

In addition to sending the email, based on the file naming convention you will trigger a function to either push data to a SQL Database (data is marked as confirmed) or push the data to the Service Bus Queue for manual review (data is marked as exported but not confirmed).

The function will need data about the file in order to process it from storage directly. The processing of the file by the functions will be completed in the next challenge, but this challenge should trigger the appropriate functions per each file and post the data to the function so that the function can make appropriate calls to storage to get the correct files.

## Task 1 - Create the logic app to fire on create blob in storage

In this task, you will create the logic app that will respond to blob creation events in storage.

1. Use the built-in events wiring from the storage account and create a new logic app
1. Connect to blob storage using the blob storage account name and key
1. Sign in to your account to connect to Event Grid (or use a managed identity if you know how to do that - I've not proven this out yet but I have an issue open)
1. Name the logic app something like `Serverless-Workshop-CSV-Processor-yyyymmmddxyz`
    - >**Note:** You cannot rename a logic app once it is created
1. Ensure the event subscription is created by reviewing from the storage account and validating that the event exists and it is pointed to your logic app

## Task 2 - Get a SendGrid account and API Key

In this task, you'll get a SendGrid account and validate the email domain to actually send email. You can get 100 free emails a day from SendGrid.

Once you have an account, you will get an API key to send emails.

Alternatively, you can try to wire up your Gmail or Microsoft account - all of these connectors are available in the logic app. The only path supported in this walkthrough is the SendGrid approach (so you're on your own if you choose another provider).

>**Note:** if you don't have a sendgrid account and want to skip this, just know that all the logic app does is format the email and subject, then sends an email to `alert` users.  You could build everything but the email part and just trust that it would work if you put sendgrid or another provider in place

## Task 3 - Build the logic app and Send an Email

In this task, you will clean up the trigger event and then put the orchestration actions in place to send an email via SendGrid.

1. Create a new logic app that is triggered by the blob created event on the storage account for data uploads
1. Parse the event data to get the blob storage file URL
1. Parse out the file name to get the number of plates
1. Send an email that contains the number of plates in the subject and the full file and number of plates in the body

## Task 4 - Create Azure Functions for each logic path

In this task you will create two new Azure Functions to respond to the orchestration from the logic app to handle the processing of the CSV file.

1. Create two new Azure functions in the LicensePlateProcessor function app
    - ProcessImports
    - ProcessReviews
1. Replace the default code in both to log information about the `data.fileUrl` which will be retrieved from the request body to prove they are working from the logic app in the next step

## Task 5 - Trigger the appropriate function from the Logic App

With the functions in place, you can now trigger them from the logic app to process the correct file on storage file creation.

The logic for the file URL is already in place, now you just need to create a condition and call the correct Azure Function from each condition with the correct information.  

The logic to process the file will be handled in the next challenge, so to complete this challenge just create the appropriate POST to trigger each function.

1. Create a condition to split processing on the file name containing `ReadyForImport`.  If the file is ready for import, trigger the `ProcessImports` Function, passing the `fileUrl`:`blobFileUrl` into the request body
1. Create a subcondition in the false branch of the above condition.  In this condition, when the file name contains `ReadyForReview` then trigger the `ProcessReviews` function, passing the `fileUrl`:`blogFileUrl` into the request body
1. Test that both paths fire correctly based on file names and that the functions log the incoming `fileUrl` from the request body.

## Conclusion

In challenge 6 you created a logic app that is triggered on blob storage created to process files.  When the file is created, the file name is parsed to get the number of plates and creates an email with important information.  In addition to sending the email, one of two paths is followed to trigger the processing for the appropriate processing function in the function app.
