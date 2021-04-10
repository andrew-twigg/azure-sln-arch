# Design your migration to Azure

Services help migrate resources to Azure:

- Azure Migrate
- Azure Database Migration Service

Azure Migrate can:

- Assess your environment's readiness to move to Azure
- Estimate monthly costs
- Get sizing recommendations for machines


## Plan

- Assess
- Migrate
- Optimise
- Monitor


### Discovery and evaluation (Assess)

- Full assessment of current environment
    - servers
    - applications
    - services in scope for migration
- Full inventory and dependency map of servers and services in scope of migration
    - how services communicate
    - each app should be fully investigated before work starts
- App migration options
    - **Rehost** existing infrastructure in Azure
        - least impact due to minimal changes
        - typically VM migrations
    - **Refactor** to PaaS services
        - reduces operational requirements
        - improve release agility
        - reduce costs
    - **Rearchitect** some systems to enable migration
        - apps become cloud native
        - new approaches to software like containers and microservices
    - **Rebuild** software if the cost to rearchitect is more than starting from scratch
    - **Replace** custom apps with modern SaaS options


### Involve key stakeholders

- Owners and superusers of apps have a wealth of experience to call on
- Involve in the planning stage to increase chance of success
- Stakeholders offer guidance in areas where the person running the migration project may have gaps


### Estimate cost savings

- Part of motivation to migrate could be cost reduction
- Use Azure Total Cost of Ownership (TCO) Calculator to estimate real costs of supporting the project in light of the company's longer-term financial goals.


### Identify tools

Several tools and services are available to help you plan and complete the four stages of migration. In some migrations, you may only need to use one or two of these tools.

| Service or tool                   | Stage                 | Use |
| --------------------------------- | --------------------- | --- |
| Azure Migrate                     | Assess and migrate    | Perform assessment and migration of VMware VMs, Hyper-V VMs, cloud VMs, and physical servers, as well as databases, data, virtual desktop infrastructure, and web applications, to Azure. |
| Service Map	                    | Assess	            | Maps communication between application components on Windows or Linux. Helps you identify dependencies when scoping what to migrate.|
| Azure TCO Calculator	            | Assess	            | Estimates your monthly running costs in Azure versus on-premises.|
| Azure Database Migration Service	| Migrate	            | Uses the Data Migration Assistant and the Azure portal to migrate database workloads to Azure.|
| Data Migration Tool	            | Migrate	            | Migrates existing databases to Azure Cosmos DB.|
| Azure Cost Management	            | Optimize	            | Helps you monitor, control, and optimize ongoing Azure costs.|
| Azure Advisor	                    | Optimize	            | Helps optimize your Azure resources for high availability, performance, and cost.|
| Azure Monitor	                    | Monitor	| Enables you to monitor your entire estate's performance. Includes application-health monitoring via enhanced telemetry, and setting up notifications.
| Azure Sentinel	                | Monitor	| Provides intelligent security analytics for your applications.|


### Deploy cloud infrastructure targets (Migrate)

Azure Migrate and Azure Database Migration Service can help create the required Azure resources. Or these may need to be manually provisioned.


### Migrate workloads

- start with a small migration and use as an opportunity to become familiar with the processss
- high level steps are
    1. prepare the source and target environments
    2. set up and start the replication between the two
    3. test the replication result
    4. fail over to Azure
- high level steps for database migrations are
    1. assess on-prem DBs
    2. migrate schemas
    3. create and run an Azure Database Migration Service project to move the data
    4. Monitor the migration


### Decommission on-prem infrastructure (Optimise)

- keep backups and archive data for historical archive
- optimise to ensure running efficiently
- analyse running costs
    - Azure Cost Managements


### Review opportunities to improve (Monitor)

Azure Monitor to capture health and performance information from Azure VMs.
