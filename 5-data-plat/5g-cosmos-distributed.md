# Distribute your data globally with Azure Cosmos DB

- Benefits of writing and replicating data to multiple regions around the world
- Read and write priorities for the regions where data is located
- Consistency settings


## Global distribution basics

Decreasing distance to data allows more content to be delivered faster. Replicating data to multiple regions around the world is a point and click op.

- replicates date into multiple regions
- add/remove regions at any time
- when adding, data is available for ops within 30 mins (assuming 100 TBs or less)
- for low latency, replicate data to regions closest to users
- for [BCDR](https://docs.microsoft.com/en-gb/azure/best-practices-availability-paired-regions) add regions based on regional pairs
- throughput and storage is replicated also
- cost also scales up


## Write to multiple regions

### Multi-master support

- option available on new Azure Cosmos DB accounts
- *active-active* model, each region is a master region that equally participats in a write-anywhere model
- Cosmos automatically converges data written to all replicas and ensures consistency and data integrity
- data propagation happens immediately


### Multi-master benefits

- single digit write latency, < 10 ms for 99% writes (non-multi-master account are < 15 ms)
- five 9s read-write availability
- unlimited write scalability and throughput
- built-in conflict resolution


### Conflict resolution

- multi-master support introduces possibility of write conflicts
- rare, only happens when item is simultaniously changed in multiple regions, before propagation happens
    - propagation is fast, hence conflicts are rare
- three conflict resolution modes
    - **Last-Writer-Wins (LWW)**, resolved on user-defined integer property in the documment (ts default)
    - **Custom, User-defined function** giving you full control by defining a function at the collection. Special stored proc with specific signature. If it fails, or doesn't exist, Azure Cosmos DB adds all conflicts into the read-only conflicts feed to be processed asynchronously
    - **Custom, Async** where Cosmos excludes all conflicts from being committed and registers them in the read-only conflicts feed for deferred resolution by the user's application. The application can perform conflict resolution asynchronously and use any logic or refer to any external source, app, or service to resolve the conflict.


## Consistency levels

Five well-defined consistency models to maximise the availability and performance of the database based on requirements:

| Consistency Level | Guarantees |
| :--: | --- |
| strong | [Linearisability](https://aphyr.com/posts/313-strong-consistency-models) guarantee where reads guaranteed to be most recent version of an item. |
| bounded staleness | Consistent prefix. Reads lag behind writes by at most k prefixes or t interval. Offers total global order except within the staleness window. |
| session | Consistent prefix. Monotonic reads, monotonic writes, and read your own writes (RYW) guarantees. |
| consistent prefix | Updates returned are some prefix of all the updates, with no gaps. |
| eventual | Out of order reads. Guarantees that in the absence of further writes, replicas within the group eventually converge. |


- Default configurable on the Azure Cosmos DB account
- Overridable on specific read request
- Default consistency level applies to data within partition sets which may span regions
- Strong/Bounded are 2x cost

