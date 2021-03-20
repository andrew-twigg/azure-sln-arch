# Create an Azure Cosmos DB database built to scale

Cosmos DB scales to meet both data velocity and volume demands.

- Create a NoSQL database with Azure Cosmos DB
- Set throughput volume using request units
- Partition keys
- Database and containers

Each Cosmos DB account is associated with one of the several data models Azure Cosmos DB supports. You create as many accounts as you need.

Supported APIs:
- Core (SQL)
- MongoDB API
- Cassandra
- Azure Tab;e
- Gremlin (graph)

Capacity modes:
- provisioned throughput
    - workloads with sustained traffic requiring predictable performance
    - geo-distribution runs on unlimited number of regions
    - per-hour billing for RUs provisioned
    - autoscale supported
- serverless (In preview - some of the below might change when GA'd)
    - workloads with intermittent or unpredictable traffic and low average-to-peak traffic ratio
    - no geo-distribution, only runs in one region
    - 50GB max storage container
    - per-hour billing for RUs consumed


cosmos-account-210320


## Request units

- Provision throughput for an entire database and share it among containers, or dedicate to specific containers.
- Most frequently set at container
- Throughput is shared across all containers, unless provisioned on a container specifically.
- No predictable throughput guarantees are provided for a container.
- Strategic scaling
    - estimate throughput needs by estimating required ops at different times
    - rate limiting applies above the provisioned throughput
- Measured per second (RU/s)
- Must be reserve in advance


### RU basics

- 1 RU equals single GET request on a 1-KB doc using a documents ID (approx.)
- consumption varies on
    - document size
    - No. properties on a doc
    - operation
    - consistency / indexing policy
- plan by [finding RU charge](https://docs.microsoft.com/en-us/azure/cosmos-db/find-request-unit-charge?tabs=dotnetv2) for most common ops
- provision number of RUs on a per-second basis
- change at any time in blocks of 100 RUs


### RU considerations

- **Item size**: As the size of an item increases, the number of RUs increases
- **Item indexing**: By default, each item is automatically indexed. RUs can be reduced by not indexing some items
- **Item property count**: RUs consumed to write an item increases as property count increases
- **Indexed properties**: limit number of indexed properties to reduce RU consumption
- **Data consistency**: Strong and bounded staleness consistency levels consume approx. 2x more RUs on read ops compared to more relaxed consistency levels.
- **Query patterns**: Query complexity affects how many RUs are consumed for an op. Azure Cosmos DB guarantees that the same query on the same data always costs the same number of RUs on repeated executions.
    - no. query results
    - no. predicates
    - nature of predicates
    - no. user defined functions
    - size of source data
    - size of result set
    - projections
- **Script usage**: Stored procs and triggers consume RUs based on the complexity of their ops. Inspect [request charge header](https://docs.microsoft.com/en-us/azure/cosmos-db/optimize-cost-reads-writes#evaluate-request-unit-charge-for-a-query) to understand how much RU capacity each op consumes.



## Partition key

A partition strategy ensures that the database can grow to efficiently run queries and transactions.

- partition strategy is a **scale-out**, or **horizontal-scaling**, scaling strategy.
- partition key defines the partition strategy
- set when container is created, can't be changed
- key decision in early development process
- used to organise data into logical divisions
    - should aim to evenly distribute ops across the database to avoid *hot partitions*
    - a *hot partition* receives many more requests than the others and can be a throughput bottleneck
- Cosmos DB manages physical partitions
    - creates by splitting existing partitions
    - no downtime
    - no perf impact
- max partition size is 20 GB
    - consider composite key if approaching partition size limit 


### Best practices when selecting partition key

- Choose a partition key that has large number of values. More values equals more scalability.
- To determine the best partition key for a read-heavy workload, review the top three to five queries, and consider the value most frequently included in the WHERE clause.
- For write-heavy workloads, understand the transactional needs of the workload, because the partition key is the scope of multi-document transactions.


Specify a partition key that satisfies core properties:

- **High cardinality**. Allows data to distribute evenly across all physical partitions.
- **Evenly distribute requests**. Total RU/s is evenly divided across all physical partitions.
- **Evenly distribute storage**. Each partition can grow to 20 GB in size.


## Example - Create Cosmos DB and container programmatically

```bash
az cosmosdb create \
    --name $NAME \
    --kind GlobalDocumentDB \
    --resource-group $RG

az cosmosdb sql database create \
    --account-name $NAME \
    --name "Products" \
    --resource-group $RG

az cosmosdb sql container create \
    --account-name $NAME \
    --database-name "Products" \
    --name "Clothing" \
    --partition-key-path "/productId" \
    --throughput 1000 \
    --resource-group $RG
```
