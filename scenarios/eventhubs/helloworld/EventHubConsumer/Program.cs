using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Microsoft.Extensions.Configuration;

Console.WriteLine("Hello, World!");

var config = new ConfigurationBuilder()
        .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
        .AddJsonFile("appsettings.json")
        .AddUserSecrets<Program>()
        .Build();

var connectionString = config.GetConnectionString("EventHub");
var eventHubName = config["EventHub:Name"];
var consumerGroup = EventHubConsumerClient.DefaultConsumerGroupName;

Console.WriteLine($"Connection string is {connectionString}");
Console.WriteLine($"EventHub name is {eventHubName}");

var consumer = new EventHubConsumerClient(consumerGroup, connectionString, eventHubName);

try
{
    // To ensure that we do not wait for an indeterminate length of time, we'll
    // stop reading after we receive five events.  For a fresh Event Hub, those
    // will be the first five that we had published.  We'll also ask for
    // cancellation after 90 seconds, just to be safe.

    using var cancellationSource = new CancellationTokenSource();
    cancellationSource.CancelAfter(TimeSpan.FromSeconds(90));

    var maximumEvents = 5;
    var eventDataRead = new List<string>();

    await foreach (PartitionEvent partitionEvent in consumer.ReadEventsAsync(cancellationSource.Token))
    {
        var eventBody = partitionEvent.Data.EventBody.ToString();
        eventDataRead.Add(eventBody);

        Console.WriteLine(eventBody);

        if (eventDataRead.Count >= maximumEvents)
        {
            break;
        }
    }

    // At this point, the data sent as the body of each event is held
    // in the eventDataRead set.
}
catch
{
    // Transient failures will be automatically retried as part of the
    // operation. If this block is invoked, then the exception was either
    // fatal or all retries were exhausted without a successful read.
}
finally
{
    await consumer.CloseAsync();
}