using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;

using static System.Console;

/// <summary>
/// Entry point. 
/// </summary>
public static class Program
{
    /// <summary>
    /// Program main.
    /// </summary>
    /// <param name="eventHubNamespace"></param>
    /// <param name="eventHubName"></param>
    /// <returns></returns>
    /// <exception cref="ArgumentException"></exception>
    public static async Task Main(string eventHubNamespace, string eventHubName)
    {
        if (string.IsNullOrEmpty(eventHubNamespace))
        {
            throw new ArgumentException($"Missing argument --event-hub-namespace. '{nameof(eventHubNamespace)}' cannot be null or empty.", nameof(eventHubNamespace));
        }

        if (string.IsNullOrWhiteSpace(eventHubName))
        {
            throw new ArgumentException($"Missing argument --event-hub-name. '{nameof(eventHubName)}' cannot be null or whitespace.", nameof(eventHubName));
        }

        string fullyQualifiedEventHubNamespace = $"{eventHubNamespace}.servicebus.windows.net";

        WriteLine($"Fully qualified event hub namespace name is {fullyQualifiedEventHubNamespace}");
        WriteLine($"Event hub name is {eventHubName}");

        EventHubConsumerClient consumer = new(EventHubConsumerClient.DefaultConsumerGroupName,
                                              fullyQualifiedEventHubNamespace,
                                              eventHubName,
                                              new DefaultAzureCredential());

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
    }
}