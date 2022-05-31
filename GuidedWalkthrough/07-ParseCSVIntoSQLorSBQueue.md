# Export parsing

In this challenge you will parse the exported CSV files based on data received from the previous challenge.  Based on the name of the file the correct function will have been triggered.

The function will review the body of the post to get the correct file from storage, will parse the CSV file, and will put the processed data into the legacy SQL ticketing system.

## Task 1 - Create the Simulated legacy database  

For part of this solution, you will port data into an Azure SQL database to simulate the legacy ticketing system.  Once license plates are verified, you will push the data into this system.  In this first task you will create the "legacy" database as a basic SQL Database at Azure.

1. Start the process to create a basic SQL Database at Azure

    Navigate to the Azure portal and search for `Azure SQL`.  On the blade for Azure SQL, select `+ Create` or `Create Azure SQL resource.`  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0001-createsqldatbase.png)  

    Choose `SQL Databases` and select `Single database` as the resource type.  Hit the `Create` button.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0002-createsqldb2.png)

    On the Create blade, select your subscription and resource group.

    For the database name, enter something like:

    ```text
    LicensePlateDataDb
    ```  

    And then you will need to select `Create new` for the server to open the create new server blade.  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0003-startthecreationofaserver.png)  

    The servername must be unique with only small chars, hyphens, and numbers, so enter something like:

    ```text
    license-plate-db-server-YYYYMMDDxyz
    ```  

    For the location, choose your region of choice that you've been using all along.  

    Select `Use SQL Authentication` [the default] for the authentication method, and enter a username and password combination.

    Note the rules for password

    - Minimum 8 characters
    - Maximum 128 characters
    - Three types of characters
    - no login info in the password

    I suggest creating a user such as:

    ```text
    serverlessuser
    ```  

    And then using a password that meets the criteria that you will remember (or keep it handy, as you will need it in the rest of this workshop).  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0004-createserver.png)  

    Hit the `OK` button.

    This will take you back to the main form.

    on the main form, change the `Compute + Storage` by hitting the `Configure database` link:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0005-configuredatabase.png)  

    Change to basic to save a ton of money.  You won't need more than basic for this solution.  It will cost $5/month at all storage levels, so just leave it to 2GB.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0007-ApplyTheSizingChange.png)  

    Change the backup to Locally-redundant.  You won't need Geo redundancy or read-only copies for this workshop.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0008-hitnext.png)  

    Hit the `Next: Networking` button.

1. Set the Networking

    The networking sets your ability to connect from your local IP and for other azure services to connect.

    For the `Network Connectivity`, select `public endpoint`.  

    On the firewall rules, select `YES` for services (allows appservice and function apps to connect) and your current client IP address (allows you to connect from SSMS from your local machine)

    ![](images/07ParseCSVIntoSQLorSBQueue/image0009-PublicAccessAndFirewallSetting.png)  

    Leave other settings to default.

    Hit the `Next:Security` button.

1. Security Review

    Ordinarily you'd want to turn on defender.  You could also add an identity to allow RBAC identity for this server.

    For this activity, you don't need to make any changes on this tab.

    Hit `Next: Additional Settings`

1. Additional Settings

    No changes here either, but you can load a backup or a sample database here if you wanted for future projects.  YOu can also set collation and maintenance windows (although there is no other option for the window).  

    Hit `Review + Create`

1. Review + Create

    Validate and Create your database

    Ensure the price, networking, and everything else is correct.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0010-creatingsqldatabase.png)  

1. Get your database connection string

    Once the database is created, navigate to the resource and get the connection string.

    You will need to put your password in the connection string.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0011-connectionstring.png)  

    Copy and paste to a notepad or code file and replace `{your password}` with the password you used previously.  Keep it handy, you'll likely need it a couple more times in this workshop.

    Add the connection string to your KeyVault:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0011.1-databaseconnectionstringkeyvault.png)  

    >**Note:** during review you might notice the wrapping on the hyphen.  You can use the arrow key to validate it is all there or you can just copy/paste to notepad to validate it is there.

    Copy and paste the URI for the Secret to notepad. Feel free to wrap it with:

    ```text
    @Microsoft.KeyVault(SecretUri=https://your-vault-name-here.vault.azure.net/secrets/LicensePlateDataDbConnection/your-version-number-here)
    ```  

    Something like:

    ```text
    @Microsoft.KeyVault(SecretUri=https://workshopvault20231231blg.vault.azure.net/secrets/LicensePlateDataDbConnection/caadd6fc7e5a4f54909774e8a605f1ce)
    ```  

1. Get the starter project

    *************The starter project is located [here](tbd)********************

    For the last parts of this workshop, you'll need a web application that has the ability to interact with the legacy data and you'll add the ability to interact with the service bus as part of the final challenge.

    First, [download the starter project](tbd), then create a new private repository to house the project.  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0011.5-gettheproject.png)  

    Extract the files to a reasonable place (likely in the same folder that you created the functions app earlier)  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0011.6-extractthefiles.png)  

    Create a local repository for the downloaded files, Then add and commit initial commit for the local repo

    ```bash
    git init
    git add .
    git commit -m "Initial Commit"
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0013-localrepo.png)

    Create a new repository:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0012-repoforadminsystem.png)  

    Leave it private and don't initialize anything in it.  

    Add the remote repository and push (the code should be on your new repository page)  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0014-repotellsyouthecode.png)  

    The commands you need to run are:

    ```bash
    git remote add origin <your-repo-link-here>
    git push -u origin main
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0015-commandstopush.png)  

    And after pushing, you should refresh the repo and see the code:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0016-codeintherepo.png)  


    >**Note:** Keep track of where you put this because you'll be modifying this code in the final challenge for our workshop.

## Task 2 - Deploy a new Azure web App

    For this next task, you will deploy the web application in order to also provision the database.  Although it's likely not the best practice, the web application code is provisioned in a way that will automatically run migrations when the app is started.  
    
    Without the database set up correctly, this will cause the application to break until the database connection strings are correctly wired up and migrations are applied. 
    
    Another side-effect of this approach is the fact that the migrations will only be able to roll forward, as building to target a migration will automatically apply any migrations, so you won't ever be able to remove a migration once it has been created.  
    
    These "gotchas" will not affect our project as we likely don't need any database changes or migration work, and having the automatic application would make any future changes easier.

1. Start the process to create the web application at Azure

    To get started, you will create a free app service web app at Azure.  Navigate to the portal and search for `App Service`.  On the `App Service` blade, click `+ Create`

    ![](images/07ParseCSVIntoSQLorSBQueue/image0017-createappservice1.png)  

    Select your subscription and resource group.

    Name the application something like:

    ```text
    LicensePlateAdminWebYYYYMMDDxyz
    ```  

    For the `Publish` select `Code`

    For the `Runtime Stack` choose `.Net 6 (LTS)`  

    Select the region you've been using for other deployments.  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0018-createappservice2.png)  

    For the windows plan, select the default new plan, or if there isn't a (New) in the name then use the `Create new` to create a new plan with a name, something like

    ```text
    ASP-RGServerlessWorkshopYYYYMMDDxyz
    ```  

    For the `Sku and size` select `Change size` and then select the `Dev/Test` option and then the `F1` Shared free tier, then hit `Apply`.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0019-createppservice-3.png)  

    Click `Next: Deployment`

1. Wire up the deployment from GitHub Actions

    On the `Deployment` tab, select `Enable` for `GitHub Actions Settings`

    Wire up your account, select the correct organization and then select the `LicensePlateAdministrationSystem` (or whatever you named yours) repository and `main` branch.  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0020-createappservice4-deployment.png)  

    >**Note**: If for some reason you can't deploy via actions here, you can use the code for the ubuntu build and add your own action with your publish profile, or you can right-click and publish from your web app locally if all else fails

    Select the `Next: Networking >` button.

1. Networking

    You cannot change anything for networking on the free tier.

    Hit `Next: Monitoring >`

1. Monitoring

    On the monitoring tab, leave the Enable Application Insights set to `Yes` and the instance to a new instance.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0021-createappservice5-monitoring.png)  

    Hit the `Review + create` button.

1. Validate and create

    On the review blade, ensure you are in the free tier and that you are using code for .Net 6

    Once ready, hit the `Create` button.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0022-createappserviceapp6-review.png)  

    Wait for the deployment to complete, which will include the GitHub action.

    Navigate to your GitHub repo to see the action run.  Note that the default is a two-stage build and deploy action and that it leverages the windows agent by default.  Unfortunately, the two-stage deployment is overkill and ubuntu will once again perform better.

1. Set the connection string on the deployed app service

    Once the app service is deployed, you can update the connection string information.  For this application, there are two connection strings, but you can just point them at the same database for simplicity.

    If you review the `appsettings.json` file in the web application for the admin system, you will see the two connection strings called out:

    ```text
    DefaultConnection
    ```  

    and

    ```text
    LicensePlateDataDbConnection
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0023-webappdbconnections.png)  

    You will need to put these both into your app service `Configuration` -> `Connection Strings` section.

    Return to your app service in the portal and select `Configuration`.  On the configuration, at the bottom in the `Connection Strings` section, create two connection strings with the names called out above and the value for each should be your database connection string retrieved earlier (don't forget to put your password in the connection string).  Set the type to `SQLAzure.`

    ![](images/07ParseCSVIntoSQLorSBQueue/image0024-licenseplateadminwebconnection1.png)  

    Ensure both are present, and don't forget to hit `Save`

    ![](images/07ParseCSVIntoSQLorSBQueue/image0025-connectionstrings2.png)  

1. Ensure the application works

    With the connection strings in place and the CI/CD working (fix any errors if you have any), you should have a deployment to the app service and the connection strings and everything should be set.

    The last thing you need to do is ensure the migrations are applied.  If everything is set correctly in your connection strings, this should happen automatically.  You may need to restart the application.
    
    Navigate to the `overview` tab for your deployment, then hit the link for the public-facing URL to see your page up and running.  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0026-navigatetothesite.png)  

    If everything is working, you are done and you should move to the final step for wiring up the repo with Ubuntu.  

    You will know it's working if you can navigate to teh `License Plates` nav item and see 10 plates that are already processed:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0026.5-workingsite.png)  

    Unfortunately, any small issue and you will likely get a 500.30 error.  This will happen if you have anything incorrect in the database connection strings, including the name of the connection strings or something as trivial as the password or a typo in the connection string.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0027-failedtostart.png)  

    If this happens, double and triple check that you have saved your connection string information correctly with the correct password for both connection strings.

    If you are certain you have everything correct in the username and password for your connection strings at Azure, then you could open the project locally and apply the two migrations.

    >**Note**: You only have to do this if the app doesn't work right away! 

    Open the project locally, ensure it builds and then open the `Package Manager Console`
    
    ![](images/07ParseCSVIntoSQLorSBQueue//image0028-packagemanagerconsole.png)  

    Next, open the `appsettings.json` file in the `LicensePlateAdminSystem` project.  Change the Connection string values for the two connection strings to your Azure database connection string.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0029-appsettingsupdated.png)  

    Save the file, then change the run the following command in the package manager console:

    ```powershell
    update-database -context ApplicationDbContext
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0030-dbupdate1.png)  

    If you get an error, make sure that you have set things correctly (including the default project selection of `LicensePlateAdminSystem`) and double-check your connection string.  Also, if you didn't allow your own IP this won't work locally.

    Next, change the `Default Project` to the `LicensePlateDataLibrary` and run the following command:
    
    ```powershell
    update-database -context LicensePlateDataDbContext
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0031-dbupdate2.png)  

    You can then open the database in SSMS to see the changes:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0032-ssms1.png)  

    Additionally, you can see the data on the database blade in the portal:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0033-queryeditorportal.png)  

1. Get your app name and secret profile variable

    Now that your app is up and running, the last step to update it for this challenge is to modify the CI/CD to use the Ubuntu action for a more efficient deployment.

    Navigate to your GitHub repo and open the .github/workflows folder, then open the main_....yml file:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0034-githubaction1.png)  

    Scroll to the bottom and you'll see the hardcoded application name and the secret that was added to your repo, in the `deploy to azure web app` task - similar to this:  

    ```yaml
    - name: Deploy to Azure Web App
        id: deploy-to-webapp
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'LicensePlateAdminWeb20231231blg'
          slot-name: 'Production'
          publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE_5CE46F0158024C3F898C127696B05340 }}
          package: .
    ```  

    >**Note** Your app-name and secret ID will be different than what is shown.  Make sure to copy your own versions of these as was generated by the azure deployment.

    Copy the app-name and the ${{ secrets.AZURE..... }} lines to notepad for use soon (or just copy the whole step, as long as you have the app-name and the publish-profile values)

1. Replace the yaml with the yaml from the repo.

    Open the repo in a new tab, keeping the action yaml file open.  in the new tab, on the root of the repository, find the file `deploy-azure-web-ubuntu.yaml`.  Open that file, then click on the `Raw` button to get just the file open

    ![](images/07ParseCSVIntoSQLorSBQueue/image0035-githubaction2-ubuntuyamlfetch.png)  

    Copy the raw yaml.  It will be exactly like this:

    ```yaml
    name: Deploy DN6 Web Ubuntu Agent

    on:
    push:
        branches:
        - main
    workflow_dispatch:

    env:
    AZURE_WEBAPP_NAME: <your-app-name-here> 

    jobs:
    build-and-deploy:
        name: 'Build And Deploy to Azure'
        runs-on: ubuntu-latest

        steps:
        - uses: actions/checkout@v2

        - name: 'Set up .NET Core'
            uses: actions/setup-dotnet@v1
            with:
            dotnet-version: '6.0.x'

        - name: 'Install Dependencies'
            run: dotnet restore
        - name: 'Build with dotnet'
            run: dotnet build --configuration Release
        - name: 'Test'
            run: dotnet test --no-restore --verbosity normal
        - name: 'dotnet publish'
            run: | 
            dotnet publish -c Release -o dotnetcorewebapp
        - name: 'Deploy to Azure WebApp'
            uses: azure/webapps-deploy@v2
            with: 
            app-name: ${{ env.AZURE_WEBAPP_NAME }}
            slot-name: 'Production'
            publish-profile: ${{ secrets.YOUR_APP_PUBLISH_PROFILE_SECRET_HERE }}  
            package: './dotnetcorewebapp' 
    ```

    Return to the original yaml file, click on the `pencil` to edit, and drop the new yaml into the file.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0036-edittheyaml.png)  

    In the new file, update the AZURE_WEBAPP_NAME: variable to your webapp name

    ![](images/07ParseCSVIntoSQLorSBQueue/image0037-editthewebappname.png)  

    Then scroll to the bottom and update the secret value to match your value:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0038-edittheyamlpublishprofile2.png)  

    Commit the changes and ensure the project builds.  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0039-commitchanges.png)

    Click on `Actions` to watch it build.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0040-watchthebuild.png)  

    You will see that using Ubuntu is orders of magnitude faster:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0041-itswayfaster.png)  

    When it's completed, ensure your page is working as expected.  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0042-itsworking.png)  

    Everything is working and your database is in place and the legacy site is up and running.

## Task 3 - Build the Storage Connection and File Parsing common logic  

For this task you will push all of the confirmed records into a simple table that stores the same information that was in the CSV File.  For our purposes, this is the final step to get data into the legacy system.  In the real world, you might also have to do things like look up the registration information and add that foreign key to the record.  

There are many ways you could go about getting the data into the database.  You could create a WebAPI and authorize a post to the endpoint with the records.  You could build an Azure Data Factory pipeline that moves the data from cosmos to SQL.  You could have someone manually review the file and enter it.  You could use an on premises SSIS package with the file. 

For this solution, you will just leverage the database library project and push directly to the application database that you created in the first task above.

In the previous challenge you already created the functions, now you just need to complete them.

Both paths will utilize the same code to parse the incoming file.  The task will be to be able to connect to the storage account via the key and be able to then get the file and then parse the file using the CSV parsing code.

The output will be a list of LicensePlates.  The application will then need to utilize the database library from the legacy system to push the list into the database.

### Create the logic to get the file from storage  

To get started, first you will need to be able to get the file from storage.  From the logic app, you were already posting the filename as part of the request body and you already have the code to get the filename in the logic.  Your current functions should look something like this:

```c#
public static class ProcessImports
{
    [FunctionName("ProcessImports")]
    public static async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
        ILogger log)
    {
        log.LogInformation("Process Imports started");

        string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        dynamic data = JsonConvert.DeserializeObject(requestBody);
        var fileUrl = data.fileUrl;
        log.LogInformation($"File url posted for processing: {fileUrl}");

        return new OkObjectResult("Processing Completed");
    }
}
```  

>**Note:** the filename is pulled from the request body.

1. Get the values for the connection from the previously created environment variables.

    In a previous task, you exported files to this storage account using the code in the `ExportPlateData` function.  In that function, you retrieved the two important environment variables for working with storage:

    ```c#
    var container = Environment.GetEnvironmentVariable("datalakeexportscontainer");
    var storageConnection = Environment.GetEnvironmentVariable("datalakeexportsconnection");
    ```  

    You will need these two lines in each of the `ProcessImports` and `ProcessReviews` CSV parsing functions.  Add them now to both functions after getting the file url:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0043-gettingconnecitoninfoforstorage.png)  

    In the `BlobStorageHelper` you already have a method for `DownloadBlob`. 

    In each of the two csv parsing functions, add the following code to get the blob that was posted for use within the individual functions:

    ```c#
    var blobHelper = new BlobStorageHelper(storageConnection, container, log);
    var theBlob = await blobHelper.DownloadBlob(BlobStorageHelper.GetBlobNameFromURL((string)fileUrl, container));
    log.LogInformation($"Blob Data Retrieved with length: {theBlob.Length}");
    ```  

    >**Note:** This code relies on a new helper function to strip out the account and container info from the blob URL to get just the name of the blob for download.  You will write that next.

1. Add the static method to get the BlobName from the Blob url.

    Add the following static method to the BlobStorageHelper class in the StorageAndFileProcessing folder for the function app:

    ```c#
    public static string GetBlobNameFromURL(string fileUrl, string container)
    {
        var containerIndex = fileUrl.ToUpper().IndexOf(container.ToUpper());
        var nextSlash = fileUrl.IndexOf("/", containerIndex);
        return fileUrl.Substring(nextSlash);
    }
    ```  

1. Push changes, Get Postman, Get the blob storage urls, and get the function URLs

    Commit the changes and push so that the project will deploy to Azure.

    While the project is deploying, get PostMan on your machine if you don't have it already [https://www.postman.com/download](https://www.postman.com/download)  

    Since these functions are https triggered, and you can get the function key and information you need, you can easily trigger them via Postman for testing.

    First, go to the storage account and get the url for one of each type of file (if you don't have one of each type, then create one of each type from the initial processing already set up):

    ![](images/07ParseCSVIntoSQLorSBQueue/image0044-eachtypeoffile.png)  

    Drill in to each one for the URL and paste the url into notepad for easy retrieval.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0045-gettheurl.png)  

    They should be something like this (obviously not exactly this):

    ```text
    https://datalakexprts20231231xyz.blob.core.windows.net/exports/20220527043359_0004_PlatesProcessedButUnconfirmed.csv
    https://datalakexprts20231231xyz.blob.core.windows.net/exports/20220527044345_0003_PlatesReadyForImport.csv
    ```  

    Ensure your function app deployed and open the function app to get the function URLs.  
    
    Get the url for `ProcessImports` and `ProcessReviews`.  
    
    ![](images/07ParseCSVIntoSQLorSBQueue/image0046-navigatetothefunction.png)  

    Also, make sure to get the function key so you can trigger the post for the function:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0047-geturl.png)  

    Also put these urls into your notepad.  They shoudl look something like this:

    ```text
    https://licenseplateprocessing20221231blg.azurewebsites.net/api/ProcessImports?code=mZ6gVdwQKD8ib8N474ZpYXXRiFeCz9HqKkz3pgyhAcsLAzFuGDoIkg==
    https://licenseplateprocessing20221231blg.azurewebsites.net/api/ProcessReviews?code=Nm1hlcmPeEfomwog7vukhXncckUXmknqW-TKpYvSUPKZAzFu556VJg==
    ```  

    Again your code and naming will be different.

1. Test the function via postman

    Open Postman.  Create a new query and switch it to Post to the process imports function:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0048-postmanimportsquery1.png)  

    Select the `Body` tab, and then switch to `Raw`.  Put your JSON in to send the file URL for your imports file.  Something like this:

    ```json
    {
    "fileUrl":"https://datalakexprts20231231xyz.blob.core.windows.net/exports/20220527044345_0003_PlatesReadyForImport.csv"
    }
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0049-postmanimports2.png)  

    Make sure you have the function open in the browser and watch the monitor logs page to see the parsing.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0050-processimportlogging.png)  

    Hit the `Send` button from postman to send the request and trigger the function:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0051-processingcompletedsuccessfullyimports.png)  

    Repeat for the other function and make sure to put the correct filename in for the reviews processing:

    Storage work is now completed.

### Create the logic to parse the CSV file

Now that you have the blob in memory, you need to parse it as a CSV and you need to then get that data into a list of object that you can store to the database or push information into the Service Bus Queue for further processing.

1. Rename the helper class in the `StorageAndFileProcessing` folder

    In the StorageAndProcessingFolder, rename the class `CreateSCVFromPlateDataInMemory` to `CSVHelper`.  Update all references.
    
    In the renamed class, add a new method as follows:

    ```c#
    public static List<LicensePlateData> GetPlateDataFromCSV(byte[] csvFileBytes)
    {
        var plateData = new List<LicensePlateData>();

        using (var ms = new MemoryStream(csvFileBytes))
        {
            using (var reader = new StreamReader(ms))
            {
                // Read file content.
                while (reader.Peek() != -1)
                {
                    var nextLineData = reader.ReadLine().Split(",");
                    if (nextLineData[0].Equals("filename", StringComparison.OrdinalIgnoreCase)) continue;
                    var lpd = new LicensePlateData();
                    lpd.FileName = nextLineData[0];
                    lpd.LicensePlateText = nextLineData[1];
                    lpd.TimeStamp = Convert.ToDateTime(nextLineData[2]);
                    plateData.Add(lpd);
                }
            }
        }
        return plateData;
    }
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0053-GetPlateDataFromCSV.png)

1. Call the parsing function

    From each of the two processing methods, call to the function to get license plate data from the export file using the following additional code:

    ```cs
    //parse the plate information
    log.LogInformation($"Parsing file: {fileUrl}");
    var plateData = CSVHelper.GetPlateDataFromCSV(theBlob);

    log.LogInformation($"Plate Data Retrieved {plateData.Count} plates");

    foreach (var p in plateData)
    {
        log.LogInformation($"Plate: {p.LicensePlateText}");
    }
    ```  

1. Test each path to ensure parsing is working

    Return to postman and re-post the requests for each function to ensure parsing is working as expected.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0054-processingtested.png)  

## Task 4 - Process Confirmed Records to Azure SQL

Now that the processing function is ready to go, it's time to move the data.  For the Imports, there are two actions to complete.  

First, you need to get the data into SQL and second you need to update Cosmos, setting each record that was imported as finalized (completed and exported set to true).  This will prevent any further exporting or evaluation of these plates.

1. Get the database library set up

    To get the records into the database, you'll need to bring in the data library from the legacy web app.  Additionally, you'll need to add the two database connection strings to the Function app.

    Open the folder where you downloaded the legacy web application.  In that folder, copy the folder for the DataLibrary project (the one with the migrations and the database context).  Paste the project folder into the same folder where your function app root is located:  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0055-datamodels.png)

    Now there is a direct conflict.  The original project and your function project both have projects and folders called `LicensePlateDataModels`.  Additionally, the legacy project has the data so that has to be the winner in any conflicts.  Really, the models on the function app side are DTO objects to get data transferred and also interact with CosmosDb.  

    There are a number of potential fixes for this, but the best solution is probably just putting the LicensePlateData into the original library project and then referencing the file from that location going forward.  You could probably get away with just adding the library data model class `LicensePlate` into the existing data  models project since they have the same namespace and you just created both in the last few hours.  However, let's do this the hard way.

    Return to the AdminSystemWebApplication and ensure you pull the latest changes (to get the YAML files).  Additionally, ensure you don't have any appsettings.json changes (if you were manually updating migrations earlier).

    Add the existing object class for `LicensePlateData` to the DataModelsProject:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0056-legacygetsthedatadto.png)  

    Copy and paste the code and bring in Newtonsoft.Json.

    Open the folders again for the function app and the admin web system.

    In the Function app, delete the current data models project, then copy and paste the library models project (the one with both data files).

    ![](images/07ParseCSVIntoSQLorSBQueue/image0057-puttingthelibraryinasthedataobjects.png)  

    Since the project is named the same, the errors will go away as soon as you copy and paste the new library with your additional file that was in the original library.

    Build the project to ensure it succeeds.

1. Reference the Database code

    Right-click the solution and bring in the existing project for the DataLibraries
    
    Then, right-click the LicensePlateProcessing functions and add the project reference for the database.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0058-gettingthelibrariesintofunctionapp.png)  

1. Leverage the database code in the `Imports` function

    In order to use the database context in the function app, you will want to leverage dependency injection.  To do this, first you will need to bring in some NuGet libraries:

    ```text
    Microsoft.Azure.Functions.Extensions
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0059-extensions.png)

    and

    ```text
    Microsoft.Extensions.DependencyInjection
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0060-di.png)  

    Once these are in place, create a new class in the project called `Startup.cs` and add the following code to the class [reference here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-dotnet-dependency-injection#register-services)  

    ```cs
    using LicensePlateDataLibrary;
    using Microsoft.Azure.Functions.Extensions.DependencyInjection;
    using Microsoft.EntityFrameworkCore;
    using Microsoft.Extensions.DependencyInjection;
    using System;

    [assembly: FunctionsStartup(typeof(LicensePlateProcessing.Startup))]

    namespace LicensePlateProcessing
    {
        public class Startup : FunctionsStartup
        {
            public override void Configure(IFunctionsHostBuilder builder)
            {
                //NOTE: Environment Variables come from Application Settings, not connection strings!
                string connectionString = Environment.GetEnvironmentVariable("LicensePlateDataDbConnection");
                builder.Services.AddDbContext<LicensePlateDataDbContext>(
                options => SqlServerDbContextOptionsExtensions.UseSqlServer(options, connectionString));
            }
        }
    }
    ```  

    Additionally, add the connection string to your `local.settings.json` file if you want to test locally (requires that you've migrated the database as expected locally):

    ```json
    {
        "IsEncrypted": false,
        "Values": {
            "AzureWebJobsStorage": "UseDevelopmentStorage=true",
            "FUNCTIONS_WORKER_RUNTIME": "dotnet",
            "LicensePlateDataDbConnection": "Server=tcp:license-plate-db-server-20231231blg.database.windows.net,1433;Initial Catalog=LicensePlateDataDb;Persist Security Info=False;User ID=serverlessuser;Password=.....;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        }
    }
    ```

1. Inject and use the context in your ProcessImports function

    With the injection ready to go, change the ProcessImports function to no longer be static, then add a variable for the database context, and a constructor to inject it. Also, remove the static attribute from the Run method:

    ```cs
    public class ProcessImports
    {
        private readonly LicensePlateDataDbContext _context;

        public ProcessImports(LicensePlateDataDbContext dbContext)
        {
            _context = dbContext;
        }

        [FunctionName("ProcessImports")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("Process Imports started");
    ```

    Add the following at the top of the method to validate context injection is working:

    ```cs
    var test = await _context.LicensePlates.ToListAsync();
    foreach (var t in test)
    {
        log.LogInformation($"Plate: {t.LicensePlateText}");
    }
    ```

    ![](images/07ParseCSVIntoSQLorSBQueue/image0062-testing.png)    

1. Get the connection string to KeyVault in the application settings.

    Make sure to add the connection string to your Azure Function as an application setting, not a connection string:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0061-connectionstring.png)

    >**Note:** Don't forget to save!

    Make sure the checkmark for the KeyVault reference turns green

    ![](images/07ParseCSVIntoSQLorSBQueue/image0061.5-keyvaultisgreen.png)  

    Push the changes and test.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0063-databasewiredup.png)


1. Push all the new plates into the database

    Now that the database is wired up, you can easily push the new ones into the database.

    First, remove the test logic that proved the database is working.

    After the plate data is parsed, change the for loop to "map" the data from the `LicensePlateData` to `LicensePlate`.  First add a new list of LicensePlate and then map each one.  After mapping, save the changes.

    ```cs
    var plates = new List<LicensePlate>();
    foreach (var p in plateData)
    {
        log.LogInformation($"Import Plate: {p.LicensePlateText}");
        var plate = new LicensePlate();
        plate.FileName = p.FileName;
        plate.TimeStamp = p.TimeStamp;
        plate.LicensePlateText = p.LicensePlateText;
        plate.IsProcessed = false;
        plates.Add(plate);
    }

    log.LogInformation("Importing all plates to database and saving changes");
    _context.LicensePlates.AddRange(plates);
    await _context.SaveChangesAsync();

    log.LogInformation("Plates imported successfully");
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0064-importplates.png)   

1. Push changes and test the import.

    Run the import and then review in the admin system.
    
    ![](images/07ParseCSVIntoSQLorSBQueue/image0065-functionimportsuccess.png)  

    And the records are in the system:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0066-DataShowsInAdminSystem.png)  

    >**Note:** IsProcessed here indicates a ticket has been issued by the system, not anything with our serverless system.

## Task 5 - Process Unconfirmed Records to Service Bus

For this task, you will push all of the records that are ready for review into the Azure Service Bus Queue so that the team can perform the required manual review on them to validate the results.

If time permits, consider also putting this into a feature flag toggle, where you can easily turn it off once the team is satisfied that the vision system is processing as expected.  In that case, you would still want to 

1. Get the connection information for service bus

    In the portal, navigate to your service bus instance.  For this work, you just need to be able to publish to the service bus, you do not need to read.

    On the service bus blade, navigate to your service bus, then open the queue and navigate to your queue.  Note the name of your service bus queue.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0067-sbqueue.png)  

    In the queue, select `Shared access policies` then `+ Add`

    ![](images/07ParseCSVIntoSQLorSBQueue/image0068-sas.png)  

    On the right-hand side, create a policy named `writetoqueue` and check the `Send` button

    ![](images/07ParseCSVIntoSQLorSBQueue/image0069-sendtoqueue.png)  

    Hit `Create`.  When completed, drill into the policy and get the info for `Primary Connection String`

    >**Important**: You will need this connection string and the name of your service bus queue in the next tasks.  

1. Add the SAS connection string for the queue to KeyVault

    Navigate to your key vault and add a new secret for `WriteOnlyUnprocessedPlatesQueue`.  Put the value from the policy just generated from the connection string into the KeyVault Secret.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0070-sbwriteonlysaskeyvault.png)  

    Get the value of the URI for the secret for use in the app settings of the function app.  Wrap it as you've done for many keys before to indicate it's a Microsoft.KeyVault reference.

1. Add the connection information to the application settings

    To get started, 

    In configuration, under App Settings, add a new application setting.  Name the setting

    ```text
    WriteOnlySBConnectionString
    ```  

    Put the value as the wrapped KeyVault secret URI:

    ```text
    @Microsoft.KeyVault(SecretUri=https....)
    ```  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0071-keyvaultsecretreference.png)  

    Save and ensure the green check mark is applied.  

    ![](images/07ParseCSVIntoSQLorSBQueue/image0072-secretrefworking.png)  

    Add another application setting for the queue name:
    
    ```text
    ServiceBusQueueName
    ```  

    Put the name of the queue in that value (such as `unprocessedplates`)  

1. Establish the Service Bus code

    To complete this challenge, you just need to push the plates that came in for review to the service bus for manual processing from the web application.  

    In previous examples you used bindings.  In this example, you will use code to directly connect to the service bus and write messages.

    Replace the `foreach (var p in plateData)` code block by wrapping it with the following code:

    ```cs
    //add the service bus connection and clients
    var sbConnectionString = Environment.GetEnvironmentVariable("WriteOnlySBConnectionString");
    var sbQueueName = Environment.GetEnvironmentVariable("ServiceBusQueueName");
    var client =  new ServiceBusClient(sbConnectionString);
    var sender =  client.CreateSender(sbQueueName);

    >**Note**: You will need to bring in the NuGet Package for `Azure.Messaging.ServiceBus`

    // create a batch
    using ServiceBusMessageBatch messageBatch = await _sender.CreateMessageBatchAsync();
    {
        try
        {
            foreach (var p in plateData)
            {
                log.LogInformation($"Plate: {p.LicensePlateText}");
            }
        }
        catch (Exception ex)
        {
            //consider logging something more verbose to application insights
            log.LogError($"{ex.Message}");
        }

        try
        {
            //update with send code in next step
        }
        catch (Exception ex)
        {
            //consider logging something more verbose to application insights
            log.LogError($"Exception sending messages as batch: {ex.Message}");
        }
        finally
        {
            //clean up resources
            await sender.DisposeAsync();
            await client.DisposeAsync();
        }
    }
    ```

    >**Note:** This code puts the original for each loop into the `try` block, and establishes the client and sender for the ServiceBus Queue in code.  

1. Compose and send the Queue message

    Replace the `foreach (var p in plateData) code with the following code block to batch the messages for sending to the queue:

    ```cs
    foreach (var p in plateData)
    {
        log.LogInformation($"Plate: {p.LicensePlateText}");

        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        sb.Append("\"fileName\":\"");
        sb.Append(p.FileName);
        sb.Append("\",\"licensePlateText\":\"");
        sb.Append(p.LicensePlateText);
        sb.Append("\",\"timeStamp\":\"");
        sb.Append(p.TimeStamp.ToString());
        sb.Append("\",\"exported\": false");
        sb.Append("}");

        var msg = sb.ToString();

        if (!messageBatch.TryAddMessage(new ServiceBusMessage(msg)))
        {
            // if an exception occurs
            throw new Exception($"Exception has occurred adding message {msg} to batch.");
        }
    }
    ```  

    Then add the following code to replace the comment `//update with send code in next step`:  

    ```cs
    await sender.SendMessagesAsync(messageBatch);
    log.LogInformation($"Batch processed {messageBatch.Count} messages to the queue for manual plate review");
    ```  

1. Check in changes and test using PostMan against the Process Reviews function

    Wait for the changes to deploy, then use your PostMan instance to trigger the Reviews function with the file Url for the review file data.

    ![](images/07ParseCSVIntoSQLorSBQueue/image0074-processreviews.png)  

1. Review the queue to see your messages

    Open the queue to see your messages were placed into the queue:

    ![](images/07ParseCSVIntoSQLorSBQueue/image0075-queuemetrics.png)  

    You can also open the Service Bus Explorer to see the messages

    ![](images/07ParseCSVIntoSQLorSBQueue/image0076-reviewthequeue.png)  

## Completed

You have now completed the bulk of the work for this solution.  The only thing that remains is working with the queue and storage from the web app to allow manual review of the images for further processing.

In this challenge you created and deployed the code for the Legacy web admin system.  You also created the backing Azure SQL database where the "ticketing" code needs to have processed plates.

You modified the two functions that were being used for processing files to either push import data to the SQL Server or push information about files that need to be reviewed into the service bus queue.  
