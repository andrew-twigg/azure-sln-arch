using System.Net;
using CosmosQuickStart;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;

var config = new ConfigurationBuilder()
        .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
        // .AddJsonFile("appsettings.json")
        .AddUserSecrets<Program>()
        .Build();

var endpoint = config.GetConnectionString("CosmosDocumentEndpoint");
var key = config.GetConnectionString("CosmosPrimaryMasterKey");

Console.WriteLine($"Endpoint is {endpoint}");
Console.WriteLine($"Key is {key}");

// Names of the database and container to create
string databaseId = "FamilyDatabase";
string containerId = "FamilyContainer";

try
{
    Console.WriteLine("Beginning operations...\n");

    // Version 3 of the .NET SDK uses generic terms 'container' (collection, graph, table) and
    // 'item' (document, edge/vertex).
    //
    // Metadata ops have no SLA and don't scale like data ops.
    // Only do these ops at start of app.
    // https://docs.microsoft.com/en-us/azure/cosmos-db/sql/troubleshoot-dot-net-sdk-slow-request?tabs=cpu-new#metadata-operations

    CosmosClient cosmosClient = new(endpoint, key);

    // using (await cosmosClient.GetDatabase(databaseId).DeleteStreamAsync()) { }

    Database database = await cosmosClient.CreateDatabaseIfNotExistsAsync(databaseId);
    Console.WriteLine("Created Database: {0}\n", database.Id);

    Container container = await database.CreateContainerIfNotExistsAsync(containerId, partitionKeyPath: "/LastName");
    Console.WriteLine("Created Container: {0}\n", container.Id);

    // Create a family object for the Andersen family
    Family andersenFamily = new()
    {
        Id = "Andersen.1",
        LastName = "Andersen",
        Parents = new Parent[]
        {
            new Parent { FirstName = "Thomas" },
            new Parent { FirstName = "Mary Kay" }
        },
        Children = new Child[]
        {
            new Child
            {
                FirstName = "Henriette Thaulow",
                Gender = "female",
                Grade = 5,
                Pets = new Pet[]
                {
                    new Pet { GivenName = "Fluffy" }
                }
            }
        },
        Address = new Address { State = "WA", County = "King", City = "Seattle" },
        IsRegistered = false
    };

    try
    {
        // Read the item to see if it exists.  
        ItemResponse<Family> andersenFamilyResponse = await container.ReadItemAsync<Family>(andersenFamily.Id, new PartitionKey(andersenFamily.LastName));
        Console.WriteLine("Item in database with id: {0} already exists\n", andersenFamilyResponse.Resource.Id);
    }
    catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
    {
        // Create an item in the container representing the Andersen family. Note we provide the value of the partition key for this item, which is "Andersen"
        ItemResponse<Family> andersenFamilyResponse = await container.CreateItemAsync<Family>(andersenFamily, new PartitionKey(andersenFamily.LastName));

        // Note that after creating the item, we can access the body of the item with the Resource property off the ItemResponse. We can also access the RequestCharge property to see the amount of RUs consumed on this request.
        Console.WriteLine("Created item in database with id: {0} Operation consumed {1} RUs.\n", andersenFamilyResponse.Resource.Id, andersenFamilyResponse.RequestCharge);
    }

    // Create a family object for the Wakefield family
    Family wakefieldFamily = new()
    {
        Id = "Wakefield.7",
        LastName = "Wakefield",
        Parents = new Parent[]
        {
            new Parent { FamilyName = "Wakefield", FirstName = "Robin" },
            new Parent { FamilyName = "Miller", FirstName = "Ben" }
        },
        Children = new Child[]
        {
            new Child
            {
                FamilyName = "Merriam",
                FirstName = "Jesse",
                Gender = "female",
                Grade = 8,
                Pets = new Pet[]
                {
                    new Pet { GivenName = "Goofy" },
                    new Pet { GivenName = "Shadow" }
                }
            },
            new Child
            {
                FamilyName = "Miller",
                FirstName = "Lisa",
                Gender = "female",
                Grade = 1
            }
        },
        Address = new Address { State = "NY", County = "Manhattan", City = "NY" },
        IsRegistered = true
    };

    try
    {
        // Read the item to see if it exists
        ItemResponse<Family> wakefieldFamilyResponse = await container.ReadItemAsync<Family>(wakefieldFamily.Id, new PartitionKey(wakefieldFamily.LastName));
        Console.WriteLine("Item in database with id: {0} already exists\n", wakefieldFamilyResponse.Resource.Id);
    }
    catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
    {
        // Create an item in the container representing the Wakefield family. Note we provide the value of the partition key for this item, which is "Wakefield"
        ItemResponse<Family> wakefieldFamilyResponse = await container.CreateItemAsync<Family>(wakefieldFamily, new PartitionKey(wakefieldFamily.LastName));

        // Note that after creating the item, we can access the body of the item with the Resource property off the ItemResponse. We can also access the RequestCharge property to see the amount of RUs consumed on this request.
        Console.WriteLine("Created item in database with id: {0} Operation consumed {1} RUs.\n", wakefieldFamilyResponse.Resource.Id, wakefieldFamilyResponse.RequestCharge);
    }

    var sqlQueryText = "SELECT * FROM c WHERE c.LastName = 'Andersen'";

    Console.WriteLine("Running query: {0}\n", sqlQueryText);

    QueryDefinition queryDefinition = new(sqlQueryText);
    using FeedIterator<Family> queryResultSetIterator = container.GetItemQueryIterator<Family>(queryDefinition);

    List<Family> families = new();

    while (queryResultSetIterator.HasMoreResults)
    {
        FeedResponse<Family> currentResultSet = await queryResultSetIterator.ReadNextAsync();
        foreach (Family family in currentResultSet)
        {
            families.Add(family);
            Console.WriteLine("\tRead {0}\n", family);
        }
    }
}
catch (CosmosException cosmosException)
{
    Console.WriteLine("Cosmos Exception with Status {0} : {1}\n", cosmosException.StatusCode, cosmosException);
}
catch (Exception e)
{
    Console.WriteLine("Error: {0}", e);
}
finally
{
    Console.WriteLine("End of demo, press any key to exit.");
    //Console.ReadKey();
}