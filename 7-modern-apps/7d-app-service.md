# Host a web application with Azure App Service

- fully managed web application hosting platform
- deployment slots for staging, production
- CI/CD support
- autoscale

## References

- [Custom Deployment Script](https://github.com/projectkudu/kudu/wiki/Custom-Deployment-Script)
- [Customising Deployments](https://github.com/projectkudu/kudu/wiki/Customizing-deployments)

## Bootstrap a web app

```sh
# install dotnet
wget -q -O - https://dot.net/v1/dotnet-install.sh | bash -s -- --version 3.1.102
export PATH="~/.dotnet:$PATH"
echo "export PATH=~/.dotnet:\$PATH" >> ~/.bashrc

# create an mvc app
dotnet new mvc --name BestBikeApp

# spin up an app
cd BestBikeApp
dotnet run

# its on port 5000
curl -kL http://127.0.0.1:5000/
```


## Manual deployment

There are a few options that you can use to manually push your code to Azure:

- Git: App Service web apps feature a Git URL that you can add as a remote repository. Pushing to the remote repository will deploy your app.
- az webapp up: webapp up is a feature of the az command-line interface that packages your app and deploys it. Unlike other deployment methods, az webapp up can create a new App Service web app for you if you haven't already created one.
- ZIP deploy: Use az webapp deployment source config-zip to send a ZIP of your application files to App Service. ZIP deploy can also be accessed via basic HTTP utilities such as curl.
- WAR deploy: It's an App Service deployment mechanism specifically designed for deploying Java web applications using WAR packages. WAR deploy can be accessed using the Kudu HTTP API located at http://<your-app-name>.scm.azurewebsites.net/api/wardeploy. If this fails try: https://<your-app-name>.scm.azurewebsites.net/api/wardeploy.
- Visual Studio: Visual Studio features an App Service deployment wizard that can walk you through the deployment process.
- FTP/S: FTP or FTPS is a traditional way of pushing your code to many hosting environments, including App Service.



