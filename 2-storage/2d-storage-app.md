# Connect an app to Azure Storage

## References

- [Storage API](https://docs.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api)


## .NET Core app

```sh
dotnet new console --name PhotoSharingApp
```
...

```sh
Welcome to .NET Core 3.1!
---------------------
SDK Version: 3.1.403

Telemetry
---------
The .NET Core tools collect usage data inorder to help us improve your experience.The data is anonymous. It is collected byMicrosoft and shared with the community. You can opt-out of telemetry by setting the DOTNET_CLI_TELEMETRY_OPTOUT environment variable to '1' or 'true' using your favorite shell.

Read more about .NET Core CLI Tools telemetry: https://aka.ms/dotnet-cli-telemetry

----------------
Explore documentation: https://aka.ms/dotnet-docs
Report issues and find source on GitHub: https://github.com/dotnet/core
Find out what's new: https://aka.ms/dotnet-whats-new
Learn about the installed HTTPS developercert: https://aka.ms/aspnet-core-https
Use 'dotnet --help' to see available commands or visit: https://aka.ms/dotnet-cli-docs
Write your first app: https://aka.ms/first-net-core-app
--------------------------------------------------------------------------------------
Getting ready...
The template "Console Application" was created successfully.

Processing post-creation actions...
Running 'dotnet restore' on PhotoSharingApp/PhotoSharingApp.csproj...
  Determining projects to restore...
  Restored /home/andrew/PhotoSharingApp/PhotoSharingApp.csproj (in 180 ms).

Restore succeeded.
```

```sh
cd PhotoSharingApp

dotnet run
```


## Create a storage account

```sh
az storage account create \
    --resource-group $RG \
    --location eastus \
    --sku Standard_LRS \
    --name adt0sa0210305
```


### Add storage client library to the app

```sh
dotnet add package Azure.Storage.Blobs
```

You need...
- Access key
- REST API endpoint

### Security

- Don't store secrets in config
- Periodically rotate keys via Key Vault (automatically)
    - Your app never has to work directly with keys
- Access keys are easy, but like root passwords
- SAS keys support permission sets and expiration


```sh
touch appsettings.json

PhotoSharingApp/vim appsettings.json

az storage account show-connection-string \
    --resource-group $RG \
    --query connectionString \
    --name photostore0adt0210306
```

write the connection string into the appsettings.json

```sh
vim PhotoSharingApp.csproj

# add this...
<ItemGroup>
    <None Update="appsettings.json">
        <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </None>
</ItemGroup>
```

```sh
dotnet add package Microsoft.Extensions.Configuration.Json
```

Add config to the app...

```sh
using System;
using Microsoft.Extensions.Configuration;
using System.IO;
using Azure.Storage.Blobs;

namespace PhotoSharingApp
{
    class Program
    {
        static void Main(string[] args)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json");

            var configuration = builder.Build();

            var connectionString = configuration.GetConnectionString("StorageAccount");
            string containerName = "photos";

            BlobContainerClient container = new BlobContainerClient(connectionString, containerName);
            container.CreateIfNotExists();
        }
    }
}
```

run it

```sh
dotnet run
```

```sh
az storage container list --account-name photostore0adt0210306
```

Get an image

```sh
wget https://github.com/MicrosoftDocs/mslearn-connect-app-to-azure-storage/blob/main/images/docs-and-friends-selfie-stick.png?raw=true -O docs-and-friends-selfie-stick.png
```

Full client app

```sh
using System;
using Microsoft.Extensions.Configuration;
using System.IO;
using Azure.Storage.Blobs;

namespace PhotoSharingApp
{
    class Program
    {
        static void Main(string[] args)
        {
        var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json");

        var configuration = builder.Build();

        Console.WriteLine("Hello World!");

        // Get a connection string to our Azure Storage account.
        var connectionString = configuration.GetConnectionString("StorageAccount");

        // Get a reference to the container client object so you can create the "photos" container
        string containerName = "photos";
        BlobContainerClient container = new BlobContainerClient(connectionString, containerName);
        container.CreateIfNotExists();

        // Uploads the image to Blob storage.  If a blb already exists with this name it will be overwritten
        string blobName = "docs-and-friends-selfie-stick";
        string fileName = "docs-and-friends-selfie-stick.png";
        BlobClient blobClient = container.GetBlobClient(blobName);
        blobClient.Upload(fileName, true);

        // List out all the blobs in the container
        var blobs = container.GetBlobs();
        foreach (var blob in blobs)
        {
            Console.WriteLine($"{blob.Name} --> Created On: {blob.Properties.CreatedOn:yyyy-MM-dd HH:mm:ss}  Size: {blob.Properties.ContentLength}");
        }
    }
    }
}
```
