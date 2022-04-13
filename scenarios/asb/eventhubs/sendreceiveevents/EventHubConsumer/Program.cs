using System.Text;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Configuration;

Console.WriteLine("Hello, World!");

var config = new ConfigurationBuilder()
        .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
        .AddJsonFile("appsettings.json")
        .AddUserSecrets<Program>()
        .Build();

var connectionString = config.GetConnectionString("EventHub");
var storageAccountConnectionString = config.GetConnectionString("StorageAccount");
var eventHubName = config["EventHub:Name"];
var consumerGroup = EventHubConsumerClient.DefaultConsumerGroupName;

Console.WriteLine($"Event Hub connection string is {connectionString}");
Console.WriteLine($"EventHub name is {eventHubName}");
Console.WriteLine($"Storage Account connection string is {storageAccountConnectionString}");

var storageClient = new BlobContainerClient(storageAccountConnectionString, "checkpoint");

static async Task ProcessEventHandler(ProcessEventArgs eventArgs)
{
    Console.WriteLine("\tReceived event: {0}", Encoding.UTF8.GetString(eventArgs.Data.Body.ToArray()));

    // Update checkpoint in the blob storage so the app only receives new events the next time it's run
    await eventArgs.UpdateCheckpointAsync(eventArgs.CancellationToken);
}

static Task ProcessErrorHandler(ProcessErrorEventArgs eventArgs)
{
    // Write details about the error to the console window
    Console.WriteLine($"\tPartition '{eventArgs.PartitionId}': an unhandled exception was encountered. This was not expected to happen.");
    Console.WriteLine(eventArgs.Exception.Message);
    return Task.CompletedTask;
}

EventProcessorClient processor;

try
{
    processor = new EventProcessorClient(
        storageClient,
        consumerGroup,
        connectionString,
        eventHubName);

    processor.ProcessEventAsync += ProcessEventHandler;
    processor.ProcessErrorAsync += ProcessErrorHandler;

    await processor.StartProcessingAsync();

    await Task.Delay(TimeSpan.FromSeconds(60));

    await processor.StopProcessingAsync();

    // To ensure that we do not wait for an indeterminate length of time, we'll
    // stop reading after we receive five events.  For a fresh Event Hub, those
    // will be the first five that we had published.  We'll also ask for
    // cancellation after 90 seconds, just to be safe.

    //    using var cancellationSource = new CancellationTokenSource();
    //    cancellationSource.CancelAfter(TimeSpan.FromSeconds(90));
    //
    //    var maximumEvents = 5;
    //    var eventDataRead = new List<string>();
    //
    //    await foreach (PartitionEvent partitionEvent in consumer.ReadEventsAsync(cancellationSource.Token))
    //    {
    //        var eventBody = partitionEvent.Data.EventBody.ToString();
    //        eventDataRead.Add(eventBody);
    //
    //        Console.WriteLine(eventBody);
    //
    //        if (eventDataRead.Count >= maximumEvents)
    //        {
    //            break;
    //        }
    //    }
    //
    //    // At this point, the data sent as the body of each event is held
    //    // in the eventDataRead set.
}
catch
{
    // Transient failures will be automatically retried as part of the
    // operation. If this block is invoked, then the exception was either
    // fatal or all retries were exhausted without a successful read.
}
finally
{
    //await processor.CloseAsync();
}
