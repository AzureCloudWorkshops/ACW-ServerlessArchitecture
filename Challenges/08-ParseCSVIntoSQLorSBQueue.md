# Azure Cloud Workshops - Serverless Architecture - Challenge 08 - Export Parsing

In this challenge you will parse the exported CSV files based on data received from the previous challenge. Based on the name of the file the correct function will have been triggered.

The function will review the body of the post to get the correct file from storage, will parse the CSV file, and will put the processed data into the legacy SQL ticketing system.  