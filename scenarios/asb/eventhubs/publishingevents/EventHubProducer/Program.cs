using System.Diagnostics;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Microsoft.Extensions.Configuration;

var config = new ConfigurationBuilder()
        .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
        .AddJsonFile("appsettings.json")
        .AddUserSecrets<Program>()
        .Build();

var connectionString = config.GetConnectionString("EventHub");
var eventHubName = config["EventHub:Name"];

Console.WriteLine($"Connection string is {connectionString}");
Console.WriteLine($"EventHub name is {eventHubName}");

// ----------------------------------------------------------------------------------------
// EventHubProducerClient
// ----------------------------------------------------------------------------------------

Console.WriteLine("EventHubProducerClient...");

// When using EventHubProducerClient the application holds responsibility for managing
// the size of events to be published. Because there is no accurate way for an application
// to calculate the size of an event, the client library offers the EventDataBatch to help.
var producer = new EventHubProducerClient(connectionString, eventHubName);

try
{
    Console.WriteLine("Creating the batch");

    // EventDataBatch exists to provide a deterministic and accurate means to measure
    // the size of a message sent to the service, minimising the chance that a publishing
    // operation will fail. It has an understanding of the maximum size and has the ability
    // to measure the exact size of an event when serialised for publishing.
    //
    // Recommended for the majority of use cases to ensure the app doesn't try to publish
    // a set of events larger than the limit.
    //
    // Partitions: Allowing automatic assignment to partitions is recommended when publishing
    // needs to be highly available and shouldn't fail if a single partition is experiencing
    // trouble. Also helps to ensure that event data is evenly distributed among all available
    // partitions, which helps ensure throughput when publishing and reading data.
    //
    // Scoped to a single publish operation. Batch is responsible for unmanaged resources so
    // dispose after publish.
    using EventDataBatch eventBatch = await producer.CreateBatchAsync();

    var eventData = new EventData("This is an event body");

    Console.WriteLine("Adding the batch");

    // Follows the TryAdd pattern, where if true then it's accepted into the batch.
    // If not true then the event isn't able to fit. Should check the return value and
    // manage the event if can't add.
    if (!eventBatch.TryAdd(eventData))
    {
        throw new Exception($"This event could not be added.");
    }

    Console.WriteLine("Sending...");

    await producer.SendAsync(eventBatch);

    Console.WriteLine("Sent.");
}
finally
{
    //
    await producer.CloseAsync();
}

// ----------------------------------------------------------------------------------------
// EventHubBufferedProducerClient
// ----------------------------------------------------------------------------------------

// Events enqueued with no options specified will be automatically routed. Because the
// producer manages publishing there is no explicit call. When the producer is closed, it
// will ensure that any remaining enqueued events have been published to one of the
// partitions.

Console.WriteLine("EventHubiBufferedProducerClient...");

// Public in 5.7.0 beta
var bufferedproducer = new EventHubBufferedProducerClient(connectionString, eventHubName);

// The failure handler is required and invoked after all allowable retries were applied.
bufferedproducer.SendEventBatchFailedAsync += args =>
{
    Debug.WriteLine($"Publishing failed for {args.EventBatch.Count} events. Error 'args.Exception.Message'");
    return Task.CompletedTask;
};

// The success handler is optional.
bufferedproducer.SendEventBatchSucceededAsync += args => {
    Debug.WriteLine($"{args.EventBatch.Count} events were published to partition: '{args.PartitionId}'.");
    return Task.CompletedTask;
};

try
{
    Console.WriteLine("Sending...");

    for (var index = 0; index < 5; ++index)
    {
        var eventData = new EventData($"Event #{index}");

        await bufferedproducer.EnqueueEventAsync(eventData);
    }

    Console.WriteLine("Sent");
}
finally
{
    // Closing the producer will flush and enqueued events that have not been published.
    await bufferedproducer.CloseAsync();
}
