# Azure Cloud Workshops - Serverless Architecture - Challenge 01 - Storage

This first challenge will establish the storage accounts for use in the project.  By the end of this first challenge you should have two storage accounts as defined in the challenge statements below.

## Step 0 - You will need a resource group

It goes without saying that you need a resource group. Create a group to house all of your resources for this workshop so you can delete them en masse when you have completed the workshop.  Place the group in a location near you where your subscription has the ability to create resources.  Name the group as you will, but a suggestion can be `RG-ACWServerlessWorkshop`

## Step 1 - Create the images storage account and images container.

For this first step, you need to create a storage account in your subscription.  You may create the account how you want, with any restrictions you want, but the images should be able to be viewed from the web so the `easiest` solution is to allow blobs to be publicly available.

Create a storage account with a container:

1. Storage Account Name -> `plateimagesyyyymmmddacw` (replace yyyymmdd with the date and acw with your initials)
1. Add a Blob storage block blob container with `hot` tier access named `images`

## Step 2 - Create the datalake storage account for exports

For the second storage account, you can make the account containers and blobs private as you will only interact with these items via code. You can also make it public if you want, it will not matter. You will use this container to store exports from the processing of the images and handling with interactions by users throughout the workshop.

Create a storage account as follows:

1. Storage Account Name -> `datalakexprtsyyyymmddacw` (replace yyyymmdd with the date and acw with your initials)
1. While it's not entirely necessary, enable the hierarchical namespace (if you don't, it won't affect this workshop)
1. Add a Blob storage block blob container with `hot` tier access named `exports`

## Conclusion

At the end of this first challenge, you'll have completed 