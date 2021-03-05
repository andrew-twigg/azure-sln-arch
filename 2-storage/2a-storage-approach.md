# Choose a data storage approach

## Learning objectives

- Classify data as structured, semi-structured, or unstructured
- Determine how data will be used
- Determine if data requires transactions


## Different approaches for storing data in the cloud

Always consider the shape of the data, how it will be used, consistency, throughput, scale, growth management

- File, blobs, queues, tables, and disks, app data (structured, semi-structured, unstructured)
- App data is nuanced (CRUD)
    - relational (azure sql), goal of increasing data integrity
    - no-sql (cosmos), can store structured, semi-structured, unstructured
        - Document databases
        - Key value stores
        - Column family stores
        - Graph databases


## Structured data

- relational
- adheres to strict schema, with all the data having same fields or properties
- often stored in database tables with rows and columns 
- integrety can be enforced through constraints
- easy to enter, query and analyse


## Semi-structured data

- known as <i>non-relational</i> or <i>NoSQL</i>
- less organised than structured data
- not relational (fields don't neatly fit into tables, rows, and columns)
- contains tags that make the organisation and hierarchy of the data apparent (key/value pairs)
- expression and structure defined by a <i>serialization language</i> which enables
    - persistence,
    - transmission,
    - parsing / reading
    - no need to know about other system, just serialization language
    - ex. yaml, xml, json


## NoSQL

- Relational DB downsides
    - retrieving objects will all relevant data can lead to complex queries
    - SQL queries aren't well suited to object-oriented data structures
    - results in poor perf when querying large amounts of data
- NoSQL is not relational
- doesn't rely on tables or SQL
- offers different data models for managing needs of data in flexible way
- easy to use / flexible
- types
    - Key-value
    - graph
    - document
- handles large amounts of data efficiently


## Unstructured data

- ambiguous
- often delivered as files (photos/videos)
- may have overall structure and come with semi-structured metadata
- actual data is unstructured
- examples
    - media
    - docs (office files)
    - text files
    - log files


## Requirements capture

- what operations on each data type
- performance requirements
- ex
    - simple lookups?
    - query the db for fields?
    - CRUD load expectations?
    - complex analytical queries?
    - how quickly do the queries need to complete?


## Transactions

Transactions help ensure data is in a correct state by enforcing data integrity requirements. If data benefits from ACID principles then choose a storage solution that supports transactions.

- group data updates together
- <i>Atomicity</i>, transaction must execute exactly once and be atomic
- <i>Consistency</i>, ensures data is consistent both before and after a transaction
- <i>Isolation</i>, ensure one transaction is not impacted by another transaction
- <i>Durability</i>, changes made due to transaction are permanently saved in the system
    - durable across failure / restart
    - available in correct state


## OLTP vs OLAP

Terminology is dated, used less frequently now.

### Online Transactional Processing

- commonly support lots of users
- quick response times
- handle large volumes of data
- highly available
- handle small, relatively simple, transactions


### Online Analytical Processing

- fewer users that OLTP
- longer response times
- can be less available
- handle large and complex transactions



