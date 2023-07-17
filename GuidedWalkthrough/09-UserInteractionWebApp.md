# Interact with the data 

In this challenge, you will complete the work by creating a .Net MVC Web application that will interact with the Service Bus to allow users to review and approve the license plates (updating the plate as necessary).  Additionally, time permitting, a reporting page can be built to review data in from the legacy system.

In the real world, you would definitely lock this application down to your users in your Tenant (or approved guests).  You might also require sign in to the application for specific roles within the application.  Time permitting, you could work on adding some authentication and authorization.

## Task 1 - Get the connection information

In the last challenge you created and deployed the web application.  In order to complete this challenge you'll need the cosmos db information, service bus connection information, and the storage account connection information.

1. Get the Cosmos, Service Bus and Storage Account connection information

    You already have a number of settings in the KeyVault, so you can just copy the settings from the function app and place them in the app settings for this project, but you will need a new service bus sas token to be able to listen and remove items from the queue.

    The items you need are:

    - ServiceBusQueueName
    - cosmosDBAuthorizationKey
    - cosmosDBContainerId
    - cosmosDbDatabaseId
    - cosmosDbEndpointUrl

    Copy the first settings from the function app (the storage container name may not exist on the other app), the only one you shouldn't have is the `ListenOnlySBConnectionString`

    >**Note:** This exercise reveals that we would have been better off putting the cosmos interaction into it's own Azure functions or Logic apps that we could also just call from the web app, rather than having to code it directly again in this `legacy` system.

    ![](images/08AdminProcessing/image0001-appsettings.png)   

    >*Note:** You should have set the App Service to work with the KeyVault in step 7.  If you didn't do that, you will need to do so at this point.

1. Create the Service Bus SAS token for `Listen`

    Leave your KeyVault blade open.

    In another tab, open your service bus queue.  Navigate to the queue for unprocessed plates, and then select the Shared Access policies and then hit the `+ Add` to add a new policy:

    ![](images/08AdminProcessing/image0006-addlistenersas.png)  

    Name the policy

    ```text
    listentoqueue
    ```  

    And select the `Listen` option

    ![](images/08AdminProcessing/image0006-addlistenersas.png)  

    Hit the `Create` button.

    Open the created sas, and then copy the `Primary connection string` value

    ![](images/08AdminProcessing/image0007-primaryconnectionsas.png)  

    >**IMPORTANT:** If your connection string contains `EntityPath=...` at the end of it, make sure to remove that part of the connection string!

    Return to the KeyVault blade and add a new secret called

    ```text
    ReadOnlyUnprocessedPlatesQueueConnection
    ```

    Add the value and then save it, then validate the value saved and get the URI

    ![](images/08AdminProcessing/image0008-readonlysaskvsecret.png)  

    Wrap the URI with the @Microsoft.KeyVault(SecretUri=....) replacing `...` with your uri.

    ```text
    @Microsoft.KeyVault(SecretUri=....)
    ```  

    Something like:

    ```text
    @Microsoft.KeyVault(SecretUri=https://workshopvault20231231blg.vault.azure.net/secrets/ReadOnlyUnprocessedPlatesQueueConnection/46e415773c54461aad7074786681cd2e)
    ```  

    Return to the app service `Configuration` and then `New application setting`

    Name the setting:

    ```text
    ReadOnlySBConnectionString
    ```  

    Then add the value for the wrapped KeyVault URI

    ![](images/08AdminProcessing/image0009-readonlysbconnectionstring.png)  

    Add and then Save, then refresh your settings.  

1. Finally, you need the storage account SAS token for the images container

    An easy way to get to private messages that are on a public endpoint is via a SAS token.

    Navigate to the plate images storage account.

    On the images container, select `Shared Access Tokens`

    - Signing Method: `Account key`
    - Signing Key: `Key 1`
    - Stored Access policy: `None`
    - Permissions: `Read`
    - Start time and Expiry time:  Change start time to yesterday, Change the expiration date to 1 year from today.

    ![](images/08AdminProcessing/image0011-storagesas.png)  

    Leave the remaining settings, then hit the `Generate SAS token and URL`

    This is the only time you'll see the key!  Copy it to clipboard, and then create a KeyVault setting for this SAS token  

    ![](images/08AdminProcessing/image0012-sastoken.png)  

    Return to the KeyVault and add the secret for 

    ```text
    ImageStorageSASToken
    ```  

    ![](images/08AdminProcessing/image0013-sastokeninvault.png)

    Validate your secret is set correctly, then grab the URI

    Wrap the URI in the typical

    ```text
    @Microsoft.KeyVault(SecretUri=...)
    ```  

    Then create an app setting to map for this SAS Token.

    Name the token 

    ```text
    PlateImagesSASToken
    ```

    Add the uri value that is wrapped as expected.

    Add, then save.  Wait a minute, then hit `Refresh`

    All the settings should be present now with the Key Vault Reference working as expected:

    ![](images/08AdminProcessing/image0010-settingscompleted.png)  

## Task 2 - Wire up ability to show plate images for selected plates

In this task, you'll add images to the pages for review of plates in the admin system.

1. Get the Image URL and SAS into the View data

    In the LicensePlateAdminSystem, select the `LicensePlateController`

    In the real world, you'd make a view model that houses the data for the image as well as information about images.

    To complete this activity, you'll just inject image information into the ViewBag (if time permits feel free to create a ViewModel).  

    On the start of the code, add th sas token  as a global variable that is readonly and set in the constructor:

    ```cs  
    private readonly LicensePlateDataDbContext _context;
    private readonly string _SASToken;

    public LicensePlatesController(LicensePlateDataDbContext context)
    {
        _context = context;
        _SASToken = Environment.GetEnvironmentVariable("PlateImagesSASToken");
    }
    ```  

    On the Details method, replace the code with the following:

    ```cs
    public async Task<IActionResult> Details(int? id)
    {
        if (id == null || _context.LicensePlates == null || !_context.LicensePlates.Any())
        {
            return NotFound();
        }

        var licensePlateData = await _context.LicensePlates
            .FirstOrDefaultAsync(m => m.Id == id);

        if (licensePlateData == null)
        {
            return NotFound();
        }

        ViewBag.ImageURL = $"{licensePlateData.FileName}?{_SASToken}";
        return View(licensePlateData);
    }
    ```  

1. Show the image on the details page

    On the `Views -> Details.cshtml` file, replace the default code to display the plate under the `<h1>Details</h1>` with the following (make sure to leave the actions in place!):

    ```html
    <div class="row">
        <div class="col-md-6">
            <div>
                <h4>LicensePlateData</h4>
                <hr />
                <dl class="row">
                    <dt class = "col-md-3">
                        @Html.DisplayNameFor(model => model.IsProcessed)
                    </dt>
                    <dd class = "col-md-9">
                        @Html.DisplayFor(model => model.IsProcessed)
                    </dd>
                    <dt class = "col-md-3">
                        @Html.DisplayNameFor(model => model.FileName)
                    </dt>
                    <dd class = "col-md-9">
                        @Html.DisplayFor(model => model.FileName)
                    </dd>
                    <dt class = "col-md-3">
                        @Html.DisplayNameFor(model => model.LicensePlateText)
                    </dt>
                    <dd class = "col-md-9">
                        @Html.DisplayFor(model => model.LicensePlateText)
                    </dd>
                    <dt class = "col-md-3">
                        @Html.DisplayNameFor(model => model.TimeStamp)
                    </dt>
                    <dd class = "col-md-9">
                        @Html.DisplayFor(model => model.TimeStamp)
                    </dd>
                </dl>
            </div>
        </div>
        <div class="col-md-6">
            <img src="@ViewBag.ImageURL" alt="the plate" />
        </div>
    </div>
    ```  

    To test this locally, you'd have to set all your environment variables.  Let's deploy and see it working in the web to save some time.  If you have time, feel free to add your local settings for all of the information (if you want to reference Key Vault this is not trivial).  

    You can run it locally, but you won't see the image (if you want to inject the sas token manually you could also do that for testing).  You would also need to process some real image data into your table.  Again, not trivial, but easy enough if you're highly motivated.

    Push your changes, the review one of the processed plates from your testing:

    ![](images/08AdminProcessing/image0014-imagesworkingondetails.png)  

    Ideally, you might also wire up the edit page to let the user change the plate, but hopefully that would never be necessary, so really it might be better to remove all processing for create/edit/delete from this form, and only let the user review data.

    Again, that's RBAC and tasks for another day.  

    However, this system is great, and we're almost done.  All that remains is the ability to work with the Service Bus Queue to handle unconfirmed plate images.

## Task 3 - Get plates from the queue in the admin system for review.

To complete this task, you will need another page that shows data from the queue (this is NOT the processed data in the database, remember, but rather images that vision failed to identify with confidence and images for confirmation).

>**Important**: I'm sure we are out of time at this point.  For this reason, we're not going to handle the scenario where a plate gets pulled from the queue and then the user fails to process it in a timely manner.  In that case, we'd want it back in the queue.  For our purposes, we will pull it and never return it, even if processing fails in the interest of saving time.

1. Create the controller code to get the data for the next image from the queue.

    In the `LicensePlatesController` add the following code to the top of the controller:

    ```cs
    private readonly LicensePlateDataDbContext _context;
    private readonly string _SASToken;
    private static string _queueConnectionString;
    private static string _queueName;
    private readonly TelemetryClient _telemetryClient;

    public LicensePlatesController(LicensePlateDataDbContext context, TelemetryClient client)
    {
        _context = context;
        _SASToken = Environment.GetEnvironmentVariable("PlateImagesSASToken");
        _queueConnectionString = Environment.GetEnvironmentVariable("ReadOnlySBConnectionString");
        _queueName = Environment.GetEnvironmentVariable("ServiceBusQueueName");
        _telemetryClient = client;
    }
    ```  

    At the top of the file, add the following using statements:

    ```cs
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.EntityFrameworkCore;
    using LicensePlateDataModels;
    using LicensePlateDataLibrary;
    using System.Text;
    using Newtonsoft.Json;
    ```  

    Ignore the fact that some may not be needed yet.  

1. Create a new DTO to respond to the queue message

    In the LicensePlateDataModels, add another class

    ```text
    LicensePlateQueueMessageData.cs
    ```  

    Put the following code in the new class file:

    ```cs
    using Newtonsoft.Json;

    namespace LicensePlateDataModels
    {
        public class LicensePlateQueueMessageData
        {
            [JsonProperty(PropertyName = "fileName")]
            public string FileName { get; set; }

            [JsonProperty(PropertyName = "licensePlateText")]
            public string LicensePlateText { get; set; }

            [JsonProperty(PropertyName = "timeStamp")]
            public DateTime TimeStamp { get; set; }

            [JsonProperty(PropertyName = "exported")]
            public bool Exported { get; set; }
        }

    }
    ```  

1. Create a new method in the controller
    
    Create a method to process the next image from the queue and display it to the user:

    ```cs
    // GET: LicensePlates/ReviewNextPlateFromQueue
    public async Task<IActionResult> ReviewNextPlateFromQueue()
    {
        var messageBody = string.Empty;
        var lpd = new LicensePlateQueueMessageData();
        try
        {
            //https://www.michalbialecki.com/en/2018/05/21/receiving-only-one-message-from-azure-service-bus/
            var queueClient = new QueueClient(_queueConnectionString, _queueName);

            queueClient.RegisterMessageHandler(
            async (message, token) =>
            {
                messageBody = Encoding.UTF8.GetString(message.Body);
                _telemetryClient.TrackEvent($"Received: {messageBody}");

                lpd = JsonConvert.DeserializeObject<LicensePlateQueueMessageData>(messageBody);
                _telemetryClient.TrackTrace($"LPD converted: {lpd.LicensePlateText} | {lpd.FileName}");

                await queueClient.CompleteAsync(message.SystemProperties.LockToken);
                await queueClient.CloseAsync();
            },
            new MessageHandlerOptions(async args => _telemetryClient.TrackException(args.Exception))
            { MaxConcurrentCalls = 1, AutoComplete = true });

            _telemetryClient.TrackTrace($"Message: {messageBody}");
        }
        catch (Exception ex)
        {
            _telemetryClient.TrackException(ex);
        }

        var autoTimeOut = DateTime.Now.AddSeconds(30);
        while (string.IsNullOrWhiteSpace(lpd?.FileName) && DateTime.Now < autoTimeOut)
        { 
            Thread.Sleep(1000);
        }

        if (string.IsNullOrWhiteSpace(lpd?.FileName))
        {
            _telemetryClient.TrackException(new Exception("No data returned from the queue for processing"));
            return RedirectToAction(nameof(Index));
        }
        //inject the sas token on the url
        var imageURL = $"{lpd?.FileName}?{_SASToken}";
        _telemetryClient.TrackTrace($"ImageURL: {imageURL}");

        ViewBag.ImageURL = imageURL;

        //open the review page with the LicensePlateData
        return View(lpd);
    }
    ```

    Adding this code will require the ServiceBus NuGetPackage.

    ![](images/08AdminProcessing/image0015-servicebus.png)  

    Ensure the code builds.

1. Add the view to handle the queue data

    In the Views folder, add a new view file:

    ```text
    ReviewNextPlateFromQueue.cshtml
    ```

    Select `Add New Razor View` for Details, and set the model to the message queue data model:

    ![](images/08AdminProcessing/image0016-messagequeuereviewview.png)  

    Replace the `html` with the following:

    ```html
    @model LicensePlateDataModels.LicensePlateQueueMessageData

    @{
        ViewData["Title"] = "Review Plate";
    }

    <h1>Next Plate: @Model.LicensePlateText</h1>

    <form asp-action="UpdateCosmos">
        <div class="row">
            <div class="col-md-6">
            <dl class="row">
                <dt class="col-md-3">@Html.DisplayNameFor(model => model.LicensePlateText)</dt>
                <dd class="col-md-9">@Html.EditorFor(model => model.LicensePlateText)</dd>
                <dt class="col-md-3">@Html.DisplayNameFor(model => model.FileName)</dt>
                <dd class="col-md-9" style="word-wrap: break-word;">@Html.DisplayFor(model => model.FileName)</dd>
                <dt class="col-md-3">@Html.DisplayNameFor(model => model.TimeStamp)</dt>
                <dd class="col-md-9" style="word-wrap: break-word;">@Html.DisplayFor(model => model.TimeStamp)</dd>
            </dl>
        </div>
            <div class="col-md-6">
                <img src="@ViewBag.ImageURL" alt="the plate image" />
            </div>
        </div>
        <div class="row">
            <div class="col-md-4">
                @Html.HiddenFor(model => model.FileName)  
                <input type="submit" value="Confirm Plate" class="btn btn-danger" />
            </div>
        </div>
    </form>
    ```  

    Then go back to the controller and add another method:

    ```cs
    // POST: LicensePlates/UpdateCosmos/lpd object
    [HttpPost, ActionName("UpdateCosmos")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> UpdateCosmos([Bind("FileName,LicensePlateText,TimeStamp")] LicensePlateQueueMessageData licensePlateData)
    {
        var plateData = new Dictionary<string, string>();
        plateData.Add(licensePlateData.FileName, licensePlateData.LicensePlateText);
        _telemetryClient.TrackEvent("User updating plate", plateData);

        //TODO: Save to Cosmos

        return RedirectToAction(nameof(Index));
    }
    ```  

1. Add a navigation item

    Finally, add a navigation item for the new method in the `Layout.cshtml` file under `Shared` under `Views`

    ```html
    <li  class="nav-item">
        <a class="nav-link text-dark" asp-area="" asp-controller="LicensePlates" asp-action="ReviewNextPlateFromQueue">Review a Plate</a>
    </li>
    ```

1. Test your changes

    Temporarily hard code your connection string and queue name into your controller:

    ![](images/08AdminProcessing/image0017-testing.png)

    Run the project and put a breakpoint on the new method to get info from the queue.

    Examine to see the output.  You should see everything but the image locally.

    ![](images/08AdminProcessing/image0018-testingpage.png)  

    >**Note: If at any point you run out of images in the queue, just use your review function post to add more to the queue.  

    Publish and review at Azure.

    There are a LOT of moving pieces so far.  It's good to ensure the solution is working at Azure.  Commit and push your changes, then review on your public site:

    ![](images/08AdminProcessing/image0019-workingatazure.png)  

    Assuming it is working, move to task 4.

    If not, remember that there is a bunch of telemetry in place.  Check the application insights for more error information:

    ![](images/08AdminProcessing/image0020-reviewappinsights.png)  

    Initially, I had the `Endpoint=...` in the connection string. It logged an exception for not wanting that Endpoint.  I updated it but broke my keyvault and this error shown above was the result.  Once I fixed all that, everything was working as expected.

## Task 4 - Update Cosmos DB to confirm the plate data

Here you need to get to the page and then post the updated text to Cosmos, along with the ability to mark the plate as NOT exported but Confirmed so that it will be exported to the finalized files.

1. Create and use a cosmos helper

    You already have similar code.  Go back to the function app and grab the cosmos helper class and the LicensePlateDataDocument class and paste them into your web solution in a folder called `Helpers`:

    ![](images/08AdminProcessing/image0021-cosmoshelper.png)  

    Bring in the cosmos library.

1. Rename the file and delete the original two methods.

    Since this is copy/paste and will have breaking changes, rename the file to

    ```text
    CosmosOperationsWeb.cs
    ```  

    Next, delete the two existing methods. Your code will do everything in one method.

    Finally, remove the `Logger` from the project 

    ```cs
    private readonly string _endpointUrl; 
    private readonly string _authorizationKey; 
    private readonly string _databaseId; 
    private readonly string _containerId; 
    private static CosmosClient _client;
    private readonly TelemetryClient _telemetryClient;

    public CosmosOperationsWeb(string endpointURL, string authorizationKey, string databaseId, string containerId, TelemetryClient client)
    {
        _endpointUrl = endpointURL;
        _authorizationKey = authorizationKey;
        _databaseId = databaseId;
        _containerId = containerId;
        _telemetryClient = client;
    }
    ```

1. Add a method to get the document(s) to modify and mark as completed.

    Unfortunately, we aren't handling duplicates well, so need to finalize them all here.  Where you just deleted the documents to export, add a new method to modify and then just update the documents.

    ```cs
    /// <summary>
    /// Update the plates as confirmed but not exported
    /// </summary>
    /// <param name="fileName">name of the file</param>
    /// <param name="timeStamp">time of the file</param>
    public async Task UpdatePlatesForConfirmation(string fileName, DateTime timeStamp, string confirmedPlateText)
    {
        _telemetryClient.TrackTrace("Started processing for update plates for confirmation");

        int modifiedCount = 0;

        if (_client is null) _client = new CosmosClient(_endpointUrl, _authorizationKey);
        var container = _client.GetContainer(_databaseId, _containerId);

        //really this should just be one, but because of our repeated use of images, need to just mark them all
        //also, this query is likely expensive in cosmos RUs and could be optimized.
        using (FeedIterator<LicensePlateDataDocument> iterator = container.GetItemLinqQueryable<LicensePlateDataDocument>()
                .Where(b => b.fileName == fileName)
                .ToFeedIterator())
        {
            //Asynchronous query execution
            while (iterator.HasMoreResults)
            {
                foreach (var item in await iterator.ReadNextAsync())
                {
                    var match = timeStamp.Second == item.timeStamp.Second
                                && timeStamp.Minute == item.timeStamp.Minute
                                && timeStamp.Hour == item.timeStamp.Hour
                                && timeStamp.Day == item.timeStamp.Day
                                && timeStamp.Month == item.timeStamp.Month
                                && timeStamp.Year == item.timeStamp.Year;
                    if (match)
                    {
                        _telemetryClient.TrackTrace($"Found {item.fileName} ready to update properties");
                        item.exported = false;
                        item.confirmed = true;
                        item.licensePlateText = confirmedPlateText;
                        var response = await container.ReplaceItemAsync(item, item.id);
                        _telemetryClient.TrackTrace($"Updated {item.fileName} as confirmed and ready for final export");
                        modifiedCount++;
                    }
                }
            }
        }

        _telemetryClient.TrackTrace($"{modifiedCount} license plates found and marked as confirmed and ready for final export as per filename/timestamp");
    }
    ```

1. Add references to the cosmos variables

    At the top of the file, add the cosmos information:

    ```cs
    private readonly LicensePlateDataDbContext _context;
    private readonly string _SASToken;
    private static string _queueConnectionString;
    private static string _queueName;
    private static string _cosmosEndpoint;
    private static string _cosmosAuthKey;
    private static string _cosmosDbId;
    private static string _cosmosContainer;
    private readonly TelemetryClient _telemetryClient;

    public LicensePlatesController(LicensePlateDataDbContext context, TelemetryClient client)
    {
        _context = context;
        _SASToken = Environment.GetEnvironmentVariable("PlateImagesSASToken");
        _queueConnectionString = Environment.GetEnvironmentVariable("ReadOnlySBConnectionString");
        _queueName = Environment.GetEnvironmentVariable("ServiceBusQueueName");
        _cosmosEndpoint = Environment.GetEnvironmentVariable("cosmosDBEndpointUrl");
        _cosmosAuthKey = Environment.GetEnvironmentVariable("cosmosDBAuthorizationKey");
        _cosmosContainer = Environment.GetEnvironmentVariable("cosmosDBContainerId");
        _cosmosDbId = Environment.GetEnvironmentVariable("cosmosDBDatabaseId");
        _telemetryClient = client;
    }
    ```  

1. Call the code from the CosmosUpdate controller method

    In the `LicensePlateController` method, create and push a request to your new method.

    ```cs
    // POST: LicensePlates/UpdateCosmos/lpd object
    [HttpPost, ActionName("UpdateCosmos")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> UpdateCosmos([Bind("LicensePlateText, FileName, TimeStamp")] LicensePlateQueueMessageData licensePlateData)
    {
        var plateData = new Dictionary<string, string>();
        plateData.Add(licensePlateData.FileName, licensePlateData.LicensePlateText);
        _telemetryClient.TrackEvent("User updating plate", plateData);

        var cosmosHelper = new CosmosOperationsWeb(_cosmosEndpoint, _cosmosAuthKey, _cosmosDbId, _cosmosContainer, _telemetryClient);
        await cosmosHelper.UpdatePlatesForConfirmation(licensePlateData.FileName, licensePlateData.TimeStamp, licensePlateData.LicensePlateText);
        _telemetryClient.TrackTrace($"Completed processing for file {licensePlateData.FileName} with ts {licensePlateData.TimeStamp}");

        return RedirectToAction(nameof(Index));
    }
    ```  

    If you want to test locally, you could inject your values for cosmos connection.  

    ![](images/08AdminProcessing/image0023-testinglocally.png)  

1. The user needs to know they did it right

    On the `index.cshtml` page, replace the ability to create a new plate with the following:

    ```html
    <div id="successdiv" class="alert alert-success alert-dismissible fade show" role="alert">
        License Plate successfully updated  
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    ```  

    At the bottom of the page, update the scripts section to the following:

    ```javascript
    @section Scripts
    {
        <script>
            $(function(){
                $("#plateTable").DataTable();
            });
            
            function notifyUserOfSuccess()
            {
                $("#successdiv").toggle();
            }
            
        </script>
        @if (ViewBag.JavaScriptFunction != null) {
        <script type="text/javascript">
            @Html.Raw(ViewBag.JavaScriptFunction)
        </script>
        }
    }
    ```  

    Return to the LicensePlatesController and update the Index method to the following:

    ```cs
    public async Task<IActionResult> Index(string? success)
    {
        if (!string.IsNullOrWhiteSpace(success) && success.Equals("showsuccess"))
        {
            ViewBag.JavaScriptFunction = "notifyUserOfSuccess";
        }

        return _context.LicensePlates != null ?
                    View(await _context.LicensePlates.ToListAsync()) :
                    Problem("Entity set 'ApplicationDbContext.LicensePlates'  is null.");
    }
    ```  

    Finally, go back to the `UpdateCosmos` method in the controller and update the return statement to the following:

    ```cs  
    return RedirectToAction(nameof(Index), new { success = "showsuccess" });
    ```  

    ![](images/08AdminProcessing/image0024-successnotification.png)  

1. Push changes and test at Azure

    Don't forget to clean up if you are testing locally so that you don't push hard-coded values.

    Commit and push changes. 

    Review a plate, update the text to match what it should be.  

    ![](images/08AdminProcessing/image0025-platereview1.png)  

    Save it by hitting `Confirm`.

    ![](images/08AdminProcessing/image0026-platereviewsuccess1.png)  


1. Review the data in Cosmos

    Ensure your changes were pushed to cosmos with the following query:

    ```sql
    select * from c where c.exported = false and c.confirmed = true
    ```  

    ![](images/08AdminProcessing/image0027-cosmoshasdata.png)

1. Trigger the timer function

    Trigger the timer function in the portal (it doesn't have to be enabled).  This will export your newly confirmed plates.

    ![](images/08AdminProcessing/image0029-exportstriggeredandfileswereexported.png)  

    Check storage to see the files:

    ![](images/08AdminProcessing/image0030-newplatesreadyforexport.png)

    If the process is working successfully, you'll see the new plate data show up in the SQL database.

    ![](images/08AdminProcessing/image0031-plateswereprocessedintosql.png)  

    The plates were processed successfully!

## Completed

At this point, you've completed the challenge.  Everything is in place successfully.

In this final challenge you built out the interaction to allow a user to manually process plates by reading plate data from the service bus queue and then processing it with the confirmed plate from the image.

## Final Thoughts

I hope you enjoyed the workshop and learned a lot.  Please let me know if you have any thoughts or concerns or issues that you would like to see improved on the workshop.





    
















