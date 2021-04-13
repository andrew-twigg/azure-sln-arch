# Backup and restore Azure SQL database

Configure backup for long term retention policies to ensure an org can recover from disasters.


## Storage for Azure SQL Database backups

- automatically creates database backups
    - kept for 7 to 35 days
    - depends on purchasing model / service tier
    - backups stored as blobs in RA-GRS
- SQL Server backup types
    - **Full backups** include everything in the database and the transaction logs. Once per week
    - **Differential backups** include everything that changed since the last full backup. Once every 12 hours
    - **Transactional backups** include the contents of the transaction logs. Every 5 to 10 minutes. Allows point in time restore.


These backups allow:
- Restore an existing database
- Restore a deleted database upto the time it was deleted
- Restore the database to an alternative location or region
- Restore a database from a long-term backup by using long-term retention (LTR)


In a failure, changes within 5 mins could be lost if the live transaction logs are lost.


## Backups and service tiers

Default backup retention period is 7 days. You can change this from 0 to 35 days.

When a database is created using the DTU purchasing model, the default retention period for that database depends on the service tier.

| Service tier | Default retention period |
| ------------ | ------------------------ |
| Basic        | 1 week                   |
| Standard     | 5 weeks                  |
| Premium      | 5 weeks                  |


## Frequency

There are backups for point-in-time restore and backups for long term retention.

- SQL databases fully support point-in-time restore
- Automatically create
    - full backups
    - differential backups
    - transaction log backups
- First backup is scheduled when database is created
- After the first full backup, all backups are scheduled and managed in the background
- Backup jobs can't be changed or disabled
- Full backup retention for LTR is 10 years


## Benefits of Azure Backups

- Reduce infra costs due to minimal up front costs and opertional expenses
- Range of backup features to backup securely in a location separate from the DB
- Distributed data copies
- Data is encrypted in transit and at rest


## Long-term backup retention policies

LTR covers the requirement of needing to retain the data backups for more than 35 days.

- Copies backups automatically made point-in-time to different blobs
- Runs in the background as low priority
- Disabled by default

```powershell
Get-AzSqlDatabase `
    -ResourceGroupName <ResourceGroupName> `
    -ServerName <ServerName> `
    | Get-AzSqlDatabaseLongTermRetentionPolicy

Set-AzSqlDatabaseBackupLongTermRetentionPolicy `
    -ServerName <ServerName> `
    -DatabaseName <DatabaseName> `
    -ResourceGroupName <ResourceGroupName> `
    -WeeklyRetention P10W `
    -YearlyRetention P3Y `
    -WeekOfYear 1
```


## Recovery

```powershell
Get-AzSqlDatabaseRestorePoint `
    -ResourceGroupName learn-bd6c1467-c9cf-43db-89d5-a8007016b6e2 `
    -DatabaseName sql-erp-db `
    -ServerName $sqlserver.ServerName
```

```sh
ResourceGroupName        : learn-bd6c1467-c9cf-43db-89d5-a8007016b6e2
ServerName               : erpserver-53903
DatabaseName             : sql-erp-db
Location                 : East US
RestorePointType         : CONTINUOUS
RestorePointCreationDate :
EarliestRestoreDate      : 9/24/19 4:21:21 PM
RestorePointLabel        :
```

