# Develop and configure an ASP.NET application that queries an Azure SQL database

A database on Azure SQL to store app data, with an ASP.NET application to query data from the database.


Create database
- CLI
    - az sql server create
    - az sql db create
- PowerShell
    - New-AzSqlServer
    - New-AzSqlDatabasei
- Portal


Create tables
- sqlcmd
- SSMS
- Portal

```sh
sqlcmd -S <server>.database.windows.net -d <database> -U <username> -P <password>
```


## Bulk importing data with bcp

There are several tools that you can use to upload data to SQL database:
- SQL Server Integration Services (SSIS)
- SQL *BULK INSERT*
- Bulk Copy Program (bcp) utility

[bcp](https://docs.microsoft.com/en-us/sql/tools/bcp-utility?view=sql-server-ver15) util advantages
- convenient
- easily scripted to import data
- requires three things
    - source data to upload
    - existing destination table
    - *format file* that defines the format of the dataand how to map the data to columns in the destination table
- source data can be in almost any structured format
- binary or character-based

Given:

```
Column1,Column2
99,some text
101,some more text
97,another bit of text
87,yet more text
33,a final bit of text
```

```sql
CREATE TABLE MyTable
(
    MyColumn1 INT NOT NULL PRIMARY KEY,
    MyColumn2 VARCHAR(50) NOT NULL
);
```

Create a format file...

```bash
bcp <database>.dbo.mytable format nul -c -f mytable.fmt -t, -S <server>.database.windows.net -U <username> -P <password>
```

...


```text
14.0
2
1       SQLCHAR             0       12      ","    1     MyColumn1                                ""
2       SQLCHAR             0       50      "\n"   2     MyColumn2                                SQL_Latin1_General_CP1_CI_AS
```


