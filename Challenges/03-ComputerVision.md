# Azure Cloud Workshops - Serverless Architecture - Challenge 03 - Computer Vision

In this third challenge, you'll deploy and integrate a Cognitive Vision Services account to read the images and try to parse out the license plates.  After creating the computer vision, you'll write code to parse out the result from cognitive services processing the license plate.

## Step 1 - Deploy Computer Vision

To get started, create a cognitive services vision account.  For this workshop you only need the vision services, but feel free to explore other cognitive services as you have time.

1. Deploy Computer Vision Cognitive services named something like `LicensePlateVisionServiceYYYYMMDDxyz`  
    - You can use the free tier but it's limited to 20 calls a minute.  If you deploy as free tier, you can scale up to Standard later if you run into timeouts (it does happen)
    - You must agree to responsible AI Notice to deploy.

1. Get the Endpoint and Key for the service

## Step 2 - Write code to interact with the computer 

For this step you need to write code to interact with computer vision within the `ProcessImage` function.

1. Create a folder to house logic for `VisionImageProcessingLogic`
1. Add a class called `LicensePlateImageProcessor.cs`
1. Create code in the class to leverage environment variables `computerVisionUrl` and `computerVisionKey`

## Step 3 - Add A secret to the vault for the vision key and set environment variables

For this last step, set the vision key into KeyVault  as a secret and then wire up the endpoint and key environment variables to match the code

1. Add the Vision key `computerVisionKey` to Keyvault, get the URI and leverage the key with the `@Microsoft.KeyVault(SecretUri=...)`
1. Set the environment variables for `computerVisionUrl` and `computerVisionKey` in the function app configuration

## Conclusion

In this challenge you created the Computer Vision account and integrated the function code to process the images from computer vision and then determine the results of the processing.
