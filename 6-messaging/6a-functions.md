# Create serverless logic with Azure Functions


## Serverless

- Function-as-a-service (FaaS) / Microservice
- hosted on cloud platform
- no need top manually provision and scale infra
- two common approaches on Azure, Logic Apps and Functions


### Functions

- serverless app platform
- host business logic without provisioning infra
- intrinsic scalability
- microbilling
- C#, F#, JavaScript, Python, and PowerShell Core
- NuGet, NPM


### Benefits

- avoids over-allocation of infra
- stateless logic
- event driven
    - runs only in response to an event, trigger
    - no need to write code watch sources
    - focus on business logic


### Drawbacks

- execution time
    - default timeout of 5 mins, configurable to 10 mins
    - can host on VM if more is needed (introducing infra)
    - HTTP requests time out at 2.5 mins
    - Durable Functions don't have timeouts
- frequency
    - estimate total usage for high frequency scenarios to understand cost
    - could be more economic to host on VM
    - scaling
        - one function app instance every 10 seconds
        - max 200 total instances


### Plans

- Consumption service plan
    - automatic scaling
    - microbilling
    - configurable timeout
- Azure App Service plan
    - avoid timeout periods by having a function run continuously on a VM
    - you take on responsibility of host app resources
    - can be more economic


### Storage

- must be linked to a storage account
- used for internal ops
    - logging
    - triggers


