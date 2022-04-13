// See https://aka.ms/new-console-template for more information
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Microsoft.Extensions.Configuration;

Console.WriteLine("Hello, World!");

var config = new ConfigurationBuilder()
        .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
        .AddJsonFile("appsettings.json")
        .AddUserSecrets<Program>()
        .Build();

var connectionString = config.GetConnectionString("EventHub");
var eventHubName = config["EventHub:Name"];

Console.WriteLine($"Connection string is {connectionString}");
Console.WriteLine($"EventHub name is {eventHubName}");

// The event hubs client types are safe to cache and use as a singleton for
// the lifetime of the application, which is best practice when events are
// being published or read regularly.
var producer = new EventHubProducerClient(connectionString, eventHubName);

try
{
    using EventDataBatch eventBatch = await producer.CreateBatchAsync();

    var counter = 0;

    for (; counter < int.MaxValue; ++counter)
    {
        var eventBody = new BinaryData($"Event Number: {counter}");
        var eventData = new EventData(eventBody);

        if (!eventBatch.TryAdd(eventData))
        {
            // At this point, the batch is full but our last event was not
            // accepted.  For our purposes, the event is unimportant so we
            // will intentionally ignore it.  In a real-world scenario, a
            // decision would have to be made as to whether the event should
            // be dropped or published on its own.

            break;
        }
    }

    // When the producer publishes the event, it will receive an
    // acknowledgment from the Event Hubs service; so long as there is no
    // exception thrown by this call, the service assumes responsibility for
    // delivery.  Your event data will be published to one of the Event Hub
    // partitions, though there may be a (very) slight delay until it is
    // available to be consumed.

    await producer.SendAsync(eventBatch);

    Console.WriteLine($"A batch of {counter} events has been published.");
}
catch
{
    // Transient failures will be automatically retried as part of the
    // operation. If this block is invoked, then the exception was either
    // fatal or all retries were exhausted without a successful publish.
}
finally
{
    await producer.CloseAsync();
}
