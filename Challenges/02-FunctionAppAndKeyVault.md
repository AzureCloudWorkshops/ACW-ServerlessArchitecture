# Azure Cloud Workshops - Serverless Architecture - Challenge 02 - Function App And KeyVault

This second challenge will establish a function app to process images and interact with Computer Vision, Cosmos, and Azure SQL.  By the end of this second challenge, you'll have the function app built and deploying via CI/CD, and you'll have the KeyVault in place.

## Step 1 - Create a Function App

To begin, create a new Azure Function App Project using the runtime of your choice.

1. Name the function app something like `LicensePlateProcessingFunctions`
1. Add a function that utilizes an Event Grid Trigger named `ProcessImage`
1. Use a binding to Azure Blob Storage to be able to read the incoming file by the blobPath: `{data.url}` from the event schema, and utilize a connection variable `plateImagesStorageConnection` which is set to the key from the plateimages / images storage account created in challenge one.

## Step 2 - Create a Repository and push the code

The next step in this challenge requires you to push your code to GitHub or a similar online repository 

1. Create a GitHub or similar repository named something like `LicensePlateProcessingFunctions` 
1. Push the code to the repository

## Step 3 - Create an Azure Function App and utilize CI/CD to publish

In this step, you need to create an Azure Function App and utilize CI/CD to publish your code to Azure

1. Create an Azure Function app named `LicensePlateProcessingYYYYMMDDxyz` on the consumption tier
1. Create the GitHub Action (or other pipeline/action) to build and deploy the function app to Azure
1. Validate the function app code has deployed in the portal

## Step 4 - Deploy a Key Vault

Next, create a KeyVault to store the secrets for this workshop.  

1. Create a Basic Key Vault named something like `WorkshopVaultYYYYMMDDxyz`
1. Get the connection string for the uploads storage acount (plate images)
1. Create a secret in the Key Vault that holds the value of the Azure Storage Connection String
1. Add the KeyVault Secret to your Azure Function App configuration
1. Give the function an identity and add the identity to the KeyVault policies for `Get` secret access

## Step 5 - Create an Event Grid topic and Subscription, add to KeyVault and reference in the Function app configuration

To respond to storage events, you will need an event grid topic and subscription

1. Create an Event Grid Topic named `egtopic-licenseuploads`
1. Get the Topic endpoint and key
1. Add the topic key to the key vault and get the secret URI
1. Add a setting for the topic key in the vault, named something like `egtopic-licenseuploads-key`, get the secret uri
1. Add a setting for the topic key retrieved from KeyVault into the Function app, named something like `eventGridTopicKey`
1. Add a setting for the topic endpoint in the function app configuration named something like `eventGridTopicEndpoint` and put the topic endpoint uri in the value (not necessary to store in the vault, but you could if you wanted to)
1. Create the event grid subscription for the event grid trigger function to respond to the topic. Name the subscription something like `ProcessImageEventFunctionSubscription`.  Filter to only the `blob created` event of storage
1. Associate the subscription to the ProcessImage Azure Function from your function app

## Step 6 - Test the integrations

This final step of part two proves that things are wired up correctly.  

1. Drop an image into the images container
1. Ensure that you see information in the function log that shows the trigger was fired and the image was processed as expected.

## Conclusion

In this second challenge, you've completed the work to handle the processing of image files as they are loaded into the images folder in an Azure Storage account.  You also created and wired up the KeyVault to protect secrets like the event topic key and the azure storage account key.
