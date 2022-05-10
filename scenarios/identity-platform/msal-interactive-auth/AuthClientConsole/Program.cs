using AuthClientConsole.Configuration;
using Microsoft.Extensions.Configuration;
using Microsoft.Identity.Client;

var config = new ConfigurationBuilder()
    .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
    .AddUserSecrets<Program>()
    .Build();

var msalSettings = config.GetRequiredSection("Msal").Get<Msal>();

Console.WriteLine($"TenantId = {msalSettings.TenantId}");
Console.WriteLine($"AppId = {msalSettings.AppId}");

var app = PublicClientApplicationBuilder
    .Create(msalSettings.AppId)
    .WithAuthority(AzureCloudInstance.AzurePublic, msalSettings.TenantId)
    .WithRedirectUri("http://localhost")
    .Build();

string[] scopes = { "user.read" };

AuthenticationResult result = await app.AcquireTokenInteractive(scopes).ExecuteAsync();

Console.WriteLine($"Token:\t{result.AccessToken}");