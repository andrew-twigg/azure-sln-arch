# Quickstart: Add sign-in with Microsoft to a web app

Registers an app in AAD and adds a role. The web app has an authz policy on the Privacy section to check for the role. You have a [manually](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-add-app-roles-in-azure-ad-apps#assign-users-and-groups-to-roles) assign the role to the user in the app.

## References

* [Quickstart](https://docs.microsoft.com/en-us/azure/active-directory/develop/web-app-quickstart?pivots=devlang-aspnet-core)
* [az ad app](https://docs.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest)
* [Azure Samples AD ASP.Net Core Open ID Connect V2](https://github.com/Azure-Samples/active-directory-aspnetcore-webapp-openidconnect-v2)

## Setup

### AAD

```sh
id=$RANDOM

app=adt-app-$id
az ad app create \
    --display-name $app \
    --web-redirect-uris https://localhost:44321/signin-oidc \
    --enable-id-token-issuance true

appId=$(az ad app list --query "[?displayName=='adt-app-$id'].appId" -o tsv)

rg=adt-rg-$id
```

The logout URL needs to be set. This CLI command fails, not sure why. Found [this](https://damienbod.com/2020/06/22/using-azure-cli-to-create-azure-app-registrations/) blog which shows it can be set directly on the logoutUrl. I set it via the Azure Portal.

```sh
az ad app update --id $appId --set web.logoutUrl=https://localhost:44321/signout-oidc2
```

Add some roles. You can also do this on create.

```sh
az ad app update --id $appId --app-roles @manifest-roles.json
```

Add a client secret...

```sh
pw=$(az ad app credential reset --id $appId --append --query password -o tsv)
```

### App

Creates a single tenant app. I think the app registration supports multi-tenant (TODO test that).

```sh
tenantId=$(az account show --query id -o tsv)

dotnet new webapp -n MyWebApp \
    -au SingleOrg \
    --domain demoware.onmicrosoft.com \
    --client-id $appId \
    --tenant-id $tenantId
```
