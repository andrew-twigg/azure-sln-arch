# Work with mutable and partial data in Azure Cache for Redis

Use Azure Cache for Redis to store frequently accessed data. 
- Transactions
- Memory management
- Cache-aside pattern



## Transactions

- Work by queueing multiple commands and executing as a group
- Commands queued inside of a transaction are guaranteed to execute without any other commands interleaving
- Transaction don't support rollback concept
- ServiceStack.Redis is a C# client library for interacting with Azure Cache for Redis
    - IRedisClient.CreateTransaction()
    - QueueCommand() / Commit()
    - Disposable - automatically issue the DISCARD command if disposed before calling Commit


```sh
REDIS_NAME=[name]

az redis create \
    --name "$REDIS_NAME" \
    --resource-group $RG \
    --location eastus \
    --vm-size C0 \
    --sku Basic
```


Create a client

```sh
cd ~
dotnet new console --name RedisData
cd RedisData
dotnet run
dotnet add package ServiceStack.Redis
```


Get the keys for the cache

```sh
REDIS_KEY=$(az redis list-keys \
    --name "$REDIS_NAME" \
    --resource-group learn-ee034284-c089-4771-971f-ecdc906c2a2c \
    --query primaryKey \
    --output tsv)

echo $REDIS_KEY
echo "$REDIS_KEY"@"$REDIS_NAME".redis.cache.windows.net:6380?ssl=true
```


Add the key to the app

```csharp
using System;
using ServiceStack.Redis;

namespace RedisData
{
    class Program
    {
        static string redisConnectionString = "<connection string>";
        static void Main(string[] args)
        {
            bool transactionResult = false;

            using (RedisClient redisClient = new RedisClient(redisConnectionString))
            using (var transaction = redisClient.CreateTransaction())
            {
                //Add multiple operations to the transaction
                transaction.QueueCommand(c => c.Set("MyKey1", "MyValue1"));
                transaction.QueueCommand(c => c.Set("MyKey2", "MyValue2"));

                //Commit and get result of transaction
                transactionResult = transaction.Commit();
            }

            if (transactionResult)
            {
                Console.WriteLine("Transaction committed");
            }
            else
            {
                Console.WriteLine("Transaction failed to commit");
            }
        }
    }
}
```

Check the status of the cache

```sh
az redis show \
    --name "$REDIS_NAME" \
    --resource-group $RG \
    --query provisioningState
```

Run the code

```sh
dotnet run
```


## Data expiration

- Automatically delete a key and value in the cache after a set amount of time
- Should aim to be efficient with memory on the cache server, its an in-memory database
- Expire stuff asap


```csharp
using System;
using ServiceStack.Redis;

namespace RedisData
{
    class Program
    {
        static string redisConnectionString = "JlXYwp4Dua6lOK5UXxPSI06UeGXHHzbU8oHen9izdx8=@adt0rc012345.redis.cache.windows.net:6380?ssl=true";
        static void Main(string[] args)
        {
            bool transactionResult = false;

            using (RedisClient redisClient = new RedisClient(redisConnectionString))
            using (var transaction = redisClient.CreateTransaction())
            {
                //Add multiple operations to the transaction
                transaction.QueueCommand(c => c.Set("MyKey1", "MyValue1"));
                transaction.QueueCommand(c => c.Set("MyKey2", "MyValue2"));

                //Add an expiration time
                transaction.QueueCommand(c => ((RedisNativeClient)c).Expire("MyKey1", 15));
                transaction.QueueCommand(c => ((RedisNativeClient)c).Expire("MyKey2", 15));

                //Commit and get result of transaction
                transactionResult = transaction.Commit();
            }

            if (transactionResult)
            {
                Console.WriteLine("Transaction committed");
            }
            else
            {
                Console.WriteLine("Transaction failed to commit");
            }
        }
    }
}
```


## Eviction policies

Since memory is critical to Azure Cache for Redis, there is support for eviction policies. An eviction policy determines what should be done with existing data when you're out of memory and attempt to insert new data.

- Memory is the most critical resource for Azure Cache for Redis (it's an in-memory database)
- Eviction policies indicate how data should be handled when running out of memory
- Types of policies
    - **noeviction**: No eviction policy. Returns an error message if you attempt to insert data.
    - **allkeys-lru**: Removes the least recently used key.
    - **allkeys-random**: Removes a random key.
    - **volatile-lru**: Removes the least recently used key out of all the keys with an expiration set.
    - **volatile-ttl**: Removes the key with the shortest time to live based on the expiration set for it.
    - **volatile-random**: Removes a random key that has an expiration set.


