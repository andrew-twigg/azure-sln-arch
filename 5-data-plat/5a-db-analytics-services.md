# Explore Azure database and analytics services

- Azure Cosmos DB
- Azure SQL Database
- Azure SQL Managed Instance
- Azure Database for MySQL
- Azure Database for PostgreSQL
- Azure Synapse Analytics
- Azure HDInsight
- Azure Databricks
- Azure Data Lake Analytics


## References

[Section Summary page](https://docs.microsoft.com/en-us/learn/modules/azure-database-fundamentals/summary)


## Azure Cosmos DB

[Technical overview](https://azure.microsoft.com/en-gb/blog/a-technical-overview-of-azure-cosmos-db/)

Cosmos is a globally distributed multi-model database service
- Elastically scale throughput and storage across regions
- Single-digit-millisecond data access
- Comprehensive SLAs
    - Throughput
    - Latency
    - Availability
    - Consistency
- Atom-record-sequence (ARS)
- Only globally distributed database system which has operationalised the [bounded staleness, session and consistent prefix](https://www.microsoft.com/en-us/research/wp-content/uploads/2011/10/ConsistencyAndBaseballReport.pdf) consistency models and exposed them to developers with clear semantics, performance/availability tradeoffs and backend SLAs.
- Automatically indexes everything it ingests and synchronously makes the index durable and highly available before acknowledging the clients updates


## Azure SQL Database

Relational database, based on the latest stable version of the Microsoft SQL Server database engine. Fully managed.

- PaaS database engine
- Managed features without user involvement
    - upgrades
    - patching
    - backups
    - monitoring
- 99.99% availability
- Automatic updates to newest SQL Server capabilities
- Azure Database Migration Service
    - Microsoft Migration Assistant generates assessment reports to guide upgrades


## Azure SQL Manageed Instance

Scalable cloud data service that provides the broadest SQL Server database engine compatibility.

- Managed PaaS service
- Provides additional options over Azure SQL Database, see [comparison](https://docs.microsoft.com/en-us/azure/azure-sql/database/features-comparison)


## Azure database for MySQL

MySQL relational database service in the cloud based on MySQL community edition engine versions 5.6, 5.7, and 8


## Big data and analytics

- [Azure Synapse Analytics](https://docs.microsoft.com/en-us/azure/synapse-analytics/) (formerly Azure SQL Data Warehouse)
- [Azure HDInsight](https://azure.microsoft.com/en-gb/services/hdinsight/)
- [Azure Data Lake Analytics](https://azure.microsoft.com/en-gb/services/data-lake-analytics/)

