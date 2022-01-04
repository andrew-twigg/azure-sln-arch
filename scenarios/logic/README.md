# Azure Logic Apps Scenarios

## References

* [Azure Logic Apps documentation](https://docs.microsoft.com/en-us/azure/logic-apps/)
* [Azure Samples, Digital Integration Hub](https://github.com/Azure-Samples/digital-integration-hub)
* [Azure Samples, Serverless Microservices Reference Architecture](https://github.com/Azure-Samples/Serverless-microservices-reference-architecture)
* [Workflow definition language](https://docs.microsoft.com/en-gb/azure/logic-apps/logic-apps-workflow-definition-language)

## Sections

* [Logic App Standard deployment with Bicep](.\logic-app-single-tenant-bicep)
* [Logic App Standard deployment with VSCode](.\logic-app-single-tenant-vscode) 

## TODOs

* [x] Read the Serverless Microservices Reference Architecture
* [x] What are [Durable Orchestrators](https://github.com/Azure-Samples/Serverless-microservices-reference-architecture/blob/main/documentation/api-endpoints.md#durable-orchestrators)?
* [ ] Azure Logic Apps hands-on technical deep dive. Create scenarios for the following:
    * [ ] Hosting (Single-tenant vs multi-tenant)
    * [ ] Provisioning
    * [ ] Monitoring
    * [ ] Security
    * [ ] Availability
    * [ ] Custom built-in connectors and can they be used for legacy system comms? See [Built-in connector extensibility](https://techcommunity.microsoft.com/t5/integrations-on-azure-blog/azure-logic-apps-running-anywhere-built-in-connector/ba-p/1921272)
    * [ ] [Stateless vs stateful workflows](https://docs.microsoft.com/en-us/azure/logic-apps/single-tenant-overview-compare#stateful-stateless), and stateful workflow resilience.
    * [ ] [Integration service environment (ISE)](https://docs.microsoft.com/en-us/azure/logic-apps/connect-virtual-network-vnet-isolated-environment-overview)
    * [ ] [App Service Environment v3 (ASEv3)](https://docs.microsoft.com/en-us/azure/app-service/environment/overview)
    * [x] [Azure Logic Apps runtime deep dive](https://techcommunity.microsoft.com/t5/integrations-on-azure-blog/azure-logic-apps-running-anywhere-runtime-deep-dive/ba-p/1835564)
    * [ ] Unit testing workflow. [Mock data](https://docs.microsoft.com/en-us/azure/logic-apps/test-logic-apps-mock-data-static-results?tabs=consumption)? Check [this blog](https://techcommunity.microsoft.com/t5/integrations-on-azure-blog/automated-testing-with-logic-apps-standard/ba-p/2960623).
    * [x] [Template deployments](https://docs.microsoft.com/en-us/azure/templates/microsoft.logic/workflows?tabs=bicep)

## Prerequisites

* .NET 5.0
    > Note: Build process also [requires](https://docs.microsoft.com/en-us/azure/azure-functions/functions-dotnet-class-library?tabs=v2%2Ccmd#supported-versions) SDK for [.NET Core 3.1](https://dotnet.microsoft.com/en-us/download/dotnet/3.1). Without it I kept getting an error from VSCode. Also, ensure the correct version of .NET is being used by setting the version in the [global.json](global.json) file.
* [Azure Functions Core Tools - 3.x version](https://github.com/Azure/azure-functions-core-tools/releases/tag/3.0.3904)
    > Not v4!
    > ```sh
    > winget install -e --id Microsoft.AzureFunctionsCoreTools -v 3.0.3904
    > ```
