# Azure Data Lake Storage Gen2

* [Overview](#overview)
* [Design Considerations](#design-considerations)
* [Stages of Processing Big Data](#stages-of-processing-big-data)

## Overview

Data warehouses and business intelligence (BI) solutions based on relational database systems. High cost and complexity of storing unstructured data. Data lakes have become a common solution to this problem.

* File-based storage
* Scalable distributed file-based storage
* Structured, semi-structured, and unstructured file support

Azure Data Lake Storage combines a file system with a storage platform to help identify insights into data. Builds on Azure Blob storage capabilities to optimise it for analytics workloads.

* Tiering and data lifecycle management
* High availability
* Security
    * Access Control Lists (ACLs)
    * Portable Operating System Interface (POSIX)
    * Directory / File level permissions
    * Encrypted at rest using Microsoft or customer-managed keys
* Durability
    * Locally redundant storage (LRS)
    * Geo-redundant storage (GRS)

## Design Considerations

Give thoughtful consideration to structure, data governance, and security.

* Types of data to be stored
* How the data will be transformed
* Who should access the data
* Data access patterns

Establish a baseline and follow best practice for ADL to ensure proper and robust implementation to support org growth and gain insight.

## Stages of Processing Big Data

* Ingest
    * Identifies technology and processes used to acquire the source data
    * Files / Logs, other unstructured data
    * Batch (Azure Synapse Analytics or Azure Data Factory)
    * Real-time (Apache Kafka for HDInsight or Stream Analytics)
* Store
    * ADLS Gen2 is a secure and scalable storage solution compatible with common big data processing tech.
* Prep and train
    * Data preparation and model training and scoring for machine learning solutions
    * Azure Synapse Analytics
    * Azure Databricks
    * Azure HSInsight
    * Azure Machine Learning
* Model and serve
    * Presentation tier
    * Visualisation tools such as Microsoft Power BI
    * Analytical data stores such as Azure synapse Analytics

## Using ADLS Gen2 in Data Analytics Workloads

* Big data processing and analytics
    * *three v's*
        * massive *volumes* or data
        * *variety* of formats
        * processed at fast *velocity*
    * provides scalable and secure distributed data store for big data services to apply data processing
    * distributed storage and processing compute enables task to be run in parallel

## Demo

See [az storage fs](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-directory-file-acl-cli) for managing HNS files.

```sh
id=$RANDOM
rg=adt-rg-$id
loc=westeurope

az group create -g $rg -l $loc

sa=adt0sa0$id

az storage account create -g $rg -n $sa \
    --location $loc \
    --sku Standard_LRS \
    --kind BlobStorage \
    --access-tier Hot \
    --enable-hierarchical-namespace

az storage fs create -n mydata --account-name $sa
az storage fs directory create --account-name $sa -n mydirectory -f mydata
az storage fs file upload --account-name $sa -s sample.txt -p mydirectory/sample.txt -f mydata
```
