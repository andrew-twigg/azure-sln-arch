# Design a data warehouse with Azure Synapse Analytics

- Explain Azure Synapse Analytics
- Types of solution workloads
- Massively Parallel Processing Concepts
- Compare Table Geometries
- Create an Azure Synapse Analytics Service


## Understand Azure Synapse Analytics

Designed to meet all analytical needs in an integrated environment if you do not have an analytical environment in place already.


### Analytics capabilities using Azure Synapse SQL through either dedicated SQL pools or SQL Serverless pools

Azure Synapse SQL:
- distributed query system which enables data warehousing and visualisation scenarios
- uses standard T-SQL experiences familiar to data engineers
- serverless and dedicated resource models to work with descriptive and diagnostic analytical scenarios
    - dedicated SQL pools to reserve processing power for data stored in SQL tables
    - for adhoc workloads, use always-available serverless SQL endpoint


![](assets/5i-azure-synapse-overview.png)


### Apache Spark pool with full support for Scala, Python, SparkSQL, and C#

- big data engineering and ML
- handles complex compute transformations that would take too long in data warehouse
- ML workloads
    - SparkML algorithms
    - AzureML integration for Apache Spark 2.4 with Linux Foundation [Delta Lake](https://delta.io)


### Integrate data with Azure Synapse pipelines

- leverages Azure Data Factory capabilities
- cloud-based ETL and data integration service at scale
    - data-driven workflows
    - orchestration
    - transformation
- create and schedule data-driven workflows (pipelines)
    - ingest data
    - ETL visually with data flows, or using Azure HDInsight Hadoop or Azure Databricks


### Azure Synapse Link for operational analytics with near real-time hybrid transactional and analytical processing

- reach out to operational data using Synapse Link
- no performance impact of the transactional datastore
    - requires enabling the feature in Synapse Analytics and source
    - creates an analytocal data store
    - data is fed to a Column store from which Synapse Link can query with no disruption


### Azure Synapse Studio - Single Web UI for all capabilities

- some features managable via portal
- Azure Synapse Studio is the best place to centrally work with all capabilities
    - explore data estate
    - TSQL script / notebook development
    - data integration pipelines
    - monitor workloads
    - manage service components


## Azure Synapse Analytics features

- workload management
- result-set cache
- materialised views
- CI/CD support via SSDT


### Workload management

Capability to prioritise query workloads using Workload Management.

- Workload groups
    - define resource to isolate and reserve resources for it
    - reserves resources for a group of requests
    - limits the amount of resources a group of requests can consume
    - access shared resources based on importance level
    - sets query timeout value
- Workload classification
    - T-SQL
    - map queries to a specific classifier to define the level of importance of a request
    - used to map to a specific workload group
- Workload importance
    - enables higher priority queries to receive resources ahead of lower priority queries
    - default is FIFO
- Result-set cache
    - caching of results in SQL pool storage
    - performance optimisation feature
- Materialized views
    - pre-compute, store, and maintain data like a table
    - automatically updated when data in underlying tables are changed
    - synchronous op that occurs as soon as data is changed


## Solution scenarios

Gartner defines a range of analytical types, including:

- Descriptive analytics
- Diagnostic analytics
- Predictive analytics
- Prescriptive analytics


### Descriptive analytics

*What is happening in my business?*
- typically found through creation of a data warehouse
- Synapse uses dedicated SQL Pool, enabling you to create a persisted data warehouse for this analysis
- also can use SQL Serverless to prepare data from files to create a data warehouse interactively


### Diagnostic analytics

*Why is this happening?*
- explore existing information, or wider search of data estate
- SQL Serverless to interactively explore data within a data lake

![](assets/5i-types-of-analytics.png)


### Predictive analytics

*What is likely to happen in the future based on previous trends and patterns?*
- Apache Spark 
- Azure Machine Learning Services
- Azure Databricks


### Prescriptive analytics

- executing actions based on real-time or near real-time analysis of data using predictive analytics
    - Apache Spark
    - Azure Synapse Link
    - Azure Stream Analytics
- Azure Synapse Analytics provides freedom to query data on own terms


## Massively parallel processing concepts

- SQL pool
    - separates compute from storage
    - bundles CPU, memory, and IO
    - an abstract, normalised measure of compute resources and performance
- Data Warehouse Units (DWUs)
- node-based architecture
    - commands issued to control node
    - runs MPP
        - optimises queries for parallel
        - passes ops to compute nodes
    - Control node
        - warehouse brain
        - front end, interacts with all apps and connections
        - distributes queries
    - Computes nodes
        - computational power
        - 1 to 60 determined by service level
- Data Movement Service (DMS)
    - data transport technology
    - coordinates data movement between compute nodes


## Table geometries

- Defines how data is sharded into distributions on the available compute nodes
- three types
    - Hash
        - uses a hash to assign each row to one distribution
        - highest query performance for joins and aggregations on large tables
    - Round Robin (default)
        - distributes evenly across all compute nodes
        - buffers of rows assigned to distributions sequentially
        - fast performance when used as a stage table for data loads
        - slow performance due to data movement
    - Replicate
        - caches a full copy of each compute node
        - fastest query performance for small tables
        - good for small-dimension tables in a star schemawith < 2 GB of storage after compression (~5x compression)
