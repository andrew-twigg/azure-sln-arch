using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;

using Shared;

var config = new ConfigurationBuilder()
    .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
    .AddJsonFile("appsettings.json")
    .AddUserSecrets<Program>()
    .Build();

const string databaseId = "StoreDatabase";
const string containerId = "CartContainer";
const string destinationContainerId = "CartContainerByState";

using CosmosClient client = new(config.GetConnectionString("CosmosSqlApi"));

var db = client.GetDatabase(databaseId);
var container = db.GetContainer(containerId);
var destinationContainer = db.GetContainer(destinationContainerId);

Container leaseContainer = await db.CreateContainerIfNotExistsAsync(
    id: "consoleLeases",
    partitionKeyPath: "/id",
    throughput: 400);

var builder = container.GetChangeFeedProcessorBuilder("migrationProcessor", (IReadOnlyCollection<CartAction> input, CancellationToken CancellationToken) =>
{
    Console.WriteLine(input.Count + " Changes Received");

    var tasks = new List<Task>();

    foreach (var doc in input)
    {
        tasks.Add(destinationContainer.CreateItemAsync(doc, new PartitionKey(doc.BuyerState)));
    }

    return Task.WhenAll(tasks);
});

var processor = builder.WithInstanceName("changeFeedConsole")
                       .WithLeaseContainer(leaseContainer)
                       .Build();

await processor.StartAsync();

Console.WriteLine("Started Change Feed Processor");
Console.WriteLine("Press any key to stop the processor...");

Console.ReadKey();

Console.WriteLine("Stopping Change Feed Processor");

await processor.StopAsync();
