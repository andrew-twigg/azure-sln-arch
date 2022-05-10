# Implement interactive authentication by using MSAL.NET

## Register the App

```sh
az ad app create --display-name "adt-app-$id" \
    --available-to-other-tenants false \
    --reply-urls "http://localhost"

appId=$(az ad app list --display-name adt-app-$id --query "[0].{appId:appId}" -o tsv)
tenantId=$(az account show --query "tenantId" -o tsv)
```

## Create Application

```sh
dotnet new console -n AuthClientConsole
cd AuthClientConsole

dotnet add package Microsoft.Identity.Client
dotnet add package Microsoft.Extensions.Configuration.UserSecrets
dotnet add package Microsoft.Extensions.Configuration.Binder
dotnet add package Microsoft.Extensions.Configuration.Json

dotnet user-secrets init

dotnet user-secrets set "Msal:AppId" $appId
dotnet user-secrets set "Msal:TenantId" $tenantId
```
