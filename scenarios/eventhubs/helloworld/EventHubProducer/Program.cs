using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;

using static System.Console;

namespace EventHubProducer;

/// <summary>
/// Entry point.
/// </summary>
public static class Program
{
    /// <summary>
    /// Program main.
    /// </summary>
    /// <param name="eventHubNamespace">The event hub namespace name.</param>
    /// <param name="eventHubName">The event hub name.</param>
    /// <returns></returns>
    /// <exception cref="ArgumentException">Parameter --event-hub-namespace is null or whitespace.</exception>
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

        EventHubProducerClient producer = new(
            fullyQualifiedEventHubNamespace,
            eventHubName,
            new DefaultAzureCredential());

        try
        {
            using EventDataBatch eventBatch = await producer.CreateBatchAsync();

            for (var counter = 0; counter < int.MaxValue; ++counter)
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
    }
}