# Connect an app to Azure Storage

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
