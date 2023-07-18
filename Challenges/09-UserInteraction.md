# Azure Cloud Workshops - Serverless Architecture - Challenge 09 - User Interaction

In this challenge, you will complete the work by creating a .Net MVC Web application that will interact with the Service Bus to allow users to review and approve the license plates (updating the plate as necessary).  Additionally, time permitting, a reporting page can be built to review data in from the legacy system.

## Task 1 - Get the connection information

In the last challenge you created and deployed the web application.  In order to complete this challenge you'll need the cosmos db information, service bus connection information, and the storage account connection information.

1. Set the Environment Variables (leverage KeyVault)

    - ServiceBusQueueName
    - cosmosDBAuthorizationKey
    - cosmosDBContainerId
    - cosmosDbDatabaseId
    - cosmosDbEndpointUrl
    - datalakeexportsconnection
    - datalakeexportscontainer
    - IdentityDbConnection
    - LicensePlateDataDbConnection

1. Create a consumer SAS token at Service Bus
    
    Create the consumer SAS token with `listen` permissions, set the connection string into KeyVault, and then leverage it as an app setting in your web application.
1. Get a SAS Token to read the images
1. Put the SAS Token into the key vault

## Task 2 - Wire up ability to show plate images for selected plates

In this task, you'll add images to the pages for review of plates in the admin system.

1. Get the image container sas token, put into key vault and leverage as an app setting
1. Retrieve images on the details page and get the actual image from storage to display on the web

## Task 3 - Get plates from the queue in the admin system for review.

To complete this task, you will need another page that shows data from the queue (this is NOT the processed data in the database, remember, but rather images that vision failed to identify with confidence and images for confirmation).

