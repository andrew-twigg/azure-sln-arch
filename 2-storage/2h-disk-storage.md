# Choose the right disk storage for your virtual machine workload


# Learning objectives

- Types of disk storage available to virtual machines
- Capabilities of different disk storage
- Use cases for each type of disk storage
- Ultra diaks, SSDs, HDDs


# Managed, unmanaged, and local disk storage

- disk roles
- ephemeral disks
- managed vs unmanaged disks


## Disk roles

Each disk can take one of three roles in a VM
- <b>OS disk</b>, one disk in each VM contains the OS system files. 
    - Max capacity 2,048 GB
- <b>Data disk</b>, one or more data virtual disks to each VM for DB files, static content, app code
    - Count depends on SKU
    - Max capacity 32,767 GB
- <b>Temp disk</b>, one per VM used for short-term storage application such as page and swap.
    - Volatile
    - Lost during maintenance events
    - Local to the server, not stored in a storage account


## Ephemeral OS disks

A virtual disk that saves data on the local VM storage. 
- lower read/write latencies than managed disk
- faster to reset to original booot state
- not resilient
- no storage cost (they are on the host)


## Managed disk

VHDs for which Azure manages all the required physical infra. Default because of all the following reasons:
- Easy to use (Azure owns the complexity)
- Stored as page blobs by Azure
- <b>Simple scalability</b>, create 50K managed disks of each type in each region in your sub
- <b>HA</b>, 99.999% stored three times. Full read/write replicas
- <b>Integration with availability sets and zones</b>. Azure automatically distributes the managed disks into different into different fault domains for resilience. Also use availability zones.
- <b>Azure Backup</b> natively supports managed disks (includes encrypted disks)
- <b>RBAC</b>
- <b>Encryption</b> via Azure Storage Service Encryption (SSE) on Azure Storage or Azure Disk Encryption (ADE), BitLocker on Windows.


## Unmanaged disks

- Stored as page blob (like managed)
- You have to own the storage account
- You have to keep track of IOPS limits
- You have to manage security and RBAC at the storage account level
- No longer widely used


## Disk types

### Performance

- IOPS - read/write ops, more = more performace
- Throughput (data transfer) - moving data on/off the disk from the host (MBps)
- SSD realise higher IOPS and throughput


### Ultra SSD

- Highest perf on Azure
- 4GB upto 64 TB
- Can adjust the IOPS and throughput while they're running without detach (takes upto an hour)

A new disk with some limitation:
- Not regions
- Only with availability zones
- ES/DS v3 only
- Data disks only
- don't support
    - snapshots
    - VM images
    - scale sets
    - ADE
    - Azure backup
    - Azure Site Recovery
- Consider for heavy workloads
    - SAP HANA


### Premium SSD

Tier down from ultra, perf option without the limitation of ultra. Guaranteed perf figures (unlike Standard tier). This is for higher perf requirements than standard disks, or when you can't sustain occasional drops in perf. Also when you can't use ultra. Good for mission critical, in medium to large orgs.


### Standard SSD

Cost effective, consistent perf at lower speeds. Latencies of 1 ms to 10 ms upto 6000 IOPS. Attach to any VM no matter what the size is. Not guaranteed perf.


### Standard HDD

Magnetic disks. For cost minimisation, less critical workloads. 
