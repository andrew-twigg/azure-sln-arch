using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Azure.Messaging.ServiceBus.Administration;
using static System.Console;

//ServiceBusClient client;

namespace TopicFilters;

/// <summary>
/// Entry point. 
/// </summary>
public class Program
{
    private const string TopicName = "TopicSubscriptionWithRuleOperationsSample";
    private const string NoFilterSubscriptionName = "NoFilterSubscription";
    private const string SqlFilterOnlySubscriptionName = "RedSqlFilterSubscription";
    private const string SqlFilterWithActionSubscriptionName = "BlueSqlFilterWithActionSubscription";
    private const string CorrelationFilterSubscriptionName = "ImportantCorrelationFilterSubscription";

    /// <summary>
    /// sfsdf
    /// </summary>
    /// <param name="serviceBusNamespace">The service bus namespace name.</param>
    /// <returns></returns>
    public static async Task Main(string serviceBusNamespace)
    {
        if (String.IsNullOrEmpty(serviceBusNamespace))
        {
            throw new ArgumentException("Missing argument --service-bus-namespace.");
        }

        WriteLine($"TopicFilters started with namespace name {serviceBusNamespace}");

        string fullyQualifiedServiceBusNamespace = $"{serviceBusNamespace}.servicebus.windows.net";

        ServiceBusClient client = new(fullyQualifiedServiceBusNamespace, new DefaultAzureCredential());
        ServiceBusAdministrationClient adminClient = new(fullyQualifiedServiceBusNamespace, new DefaultAzureCredential());

        WriteLine($"Creating topic {TopicName}");
        await adminClient.CreateTopicAsync(TopicName);

        ServiceBusSender sender = client.CreateSender(TopicName);

        // First Subscription is already created with default rule. Leave as is.
        WriteLine($"Creating subscription {NoFilterSubscriptionName}");
        await adminClient.CreateSubscriptionAsync(TopicName, NoFilterSubscriptionName);

        WriteLine($"SubscriptionName: {NoFilterSubscriptionName}, Removing and re-adding Default Rule");
        await adminClient.DeleteRuleAsync(TopicName, NoFilterSubscriptionName, RuleProperties.DefaultRuleName);
        await adminClient.CreateRuleAsync(TopicName, NoFilterSubscriptionName,
            new CreateRuleOptions(RuleProperties.DefaultRuleName, new TrueRuleFilter()));

        // 2nd Subscription: Add SqlFilter on Subscription 2
        // In this scenario, rather than deleting the default rule after creating the subscription,
        // we will create the subscription along with our desired rule in a single operation.
        // See https://docs.microsoft.com/en-us/azure/service-bus-messaging/topic-filters to learn more about topic filters.
        WriteLine($"Creating subscription {SqlFilterOnlySubscriptionName}");
        await adminClient.CreateSubscriptionAsync(
            new CreateSubscriptionOptions(TopicName, SqlFilterOnlySubscriptionName),
            new CreateRuleOptions { Name = "RedSqlRule", Filter = new SqlRuleFilter("Color = 'Red'") });
 
        // 3rd Subscription: Add the SqlFilter Rule and Action
        // See https://docs.microsoft.com/en-us/azure/service-bus-messaging/topic-filters#actions to learn more about actions.
        WriteLine($"Creating subscription {SqlFilterWithActionSubscriptionName}");
        await adminClient.CreateSubscriptionAsync(
            new CreateSubscriptionOptions(TopicName, SqlFilterWithActionSubscriptionName),
            new CreateRuleOptions
            {
                Name = "BlueSqlRule",
                Filter = new SqlRuleFilter("Color = 'Blue'"),
                Action = new SqlRuleAction("SET Color = 'BlueProcessed'")
            });

        // 4th Subscription: Add Correlation Filter on Subscription 4
        WriteLine($"Creating subscription {CorrelationFilterSubscriptionName}");
        await adminClient.CreateSubscriptionAsync(
            new CreateSubscriptionOptions(TopicName, CorrelationFilterSubscriptionName),
            new CreateRuleOptions
            {
                Name = "ImportantCorrelationRule",
                Filter = new CorrelationRuleFilter { Subject = "Red", CorrelationId = "important" }
            });

        // Get Rules on Subscription, called here only for one subscription as example
        var rules = adminClient.GetRulesAsync(TopicName, CorrelationFilterSubscriptionName);
        await foreach (var rule in rules)
        {
            WriteLine($"GetRules:: SubscriptionName: {CorrelationFilterSubscriptionName}, CorrelationFilter Name: {rule.Name}, Rule: {rule.Filter}");
        }

        // Send messages to Topic
        await SendMessagesAsync(sender);

        // Receive messages from 'NoFilterSubscription'. Should receive all 9 messages 
        await ReceiveMessagesAsync(client, NoFilterSubscriptionName);

        // Receive messages from 'SqlFilterOnlySubscription'. Should receive all messages with Color = 'Red' i.e 3 messages
        await ReceiveMessagesAsync(client, SqlFilterOnlySubscriptionName);

        // Receive messages from 'SqlFilterWithActionSubscription'. Should receive all messages with Color = 'Blue'
        // i.e 3 messages AND all messages should have color set to 'BlueProcessed'
        await ReceiveMessagesAsync(client, SqlFilterWithActionSubscriptionName);

        // Receive messages from 'CorrelationFilterSubscription'. Should receive all messages  with Color = 'Red' and CorrelationId = "important"
        // i.e 1 message
        await ReceiveMessagesAsync(client, CorrelationFilterSubscriptionName);
        ResetColor();

        WriteLine("=======================================================================");
        WriteLine("Completed Receiving all messages. Disposing clients and deleting topic.");
        WriteLine("=======================================================================");

        WriteLine("Disposing sender");
        await sender.CloseAsync();
        WriteLine("Disposing client");
        await client.DisposeAsync();

        WriteLine("Deleting topic");

        // Deleting the topic will handle deleting all the subscriptions as well.
        await adminClient.DeleteTopicAsync(TopicName);
    }

    private static async Task SendMessagesAsync(ServiceBusSender sender)
    {
        WriteLine($"==========================================================================");
        WriteLine("Creating messages to send to Topic");
        List<ServiceBusMessage> messages = new ();
        messages.Add(CreateMessage(subject: "Red"));
        messages.Add(CreateMessage(subject: "Blue"));
        messages.Add(CreateMessage(subject: "Red", correlationId: "important"));
        messages.Add(CreateMessage(subject: "Blue", correlationId: "important"));
        messages.Add(CreateMessage(subject: "Red", correlationId: "notimportant"));
        messages.Add(CreateMessage(subject: "Blue", correlationId: "notimportant"));
        messages.Add(CreateMessage(subject: "Green"));
        messages.Add(CreateMessage(subject: "Green", correlationId: "important"));
        messages.Add(CreateMessage(subject: "Green", correlationId: "notimportant"));

        WriteLine("Sending messages to send to Topic");
        await sender.SendMessagesAsync(messages);
        WriteLine($"==========================================================================");
    }

    private static ServiceBusMessage CreateMessage(string subject, string correlationId = null)
    {
        ServiceBusMessage message = new() {Subject = subject};
        message.ApplicationProperties.Add("Color", subject);

        if (correlationId != null)
        {
            message.CorrelationId = correlationId;
        }

        PrintMessage(message);

        return message;
    }

    private static void PrintMessage(ServiceBusMessage message)
    {
        ForegroundColor = (ConsoleColor) Enum.Parse(typeof(ConsoleColor), message.Subject);
        WriteLine($"Created message with color: {message.ApplicationProperties["Color"]}, CorrelationId: {message.CorrelationId}");
        ResetColor();
    }
    
    private static void PrintReceivedMessage(ServiceBusReceivedMessage message)
    {
        ForegroundColor = (ConsoleColor) Enum.Parse(typeof(ConsoleColor), message.Subject);
        WriteLine($"Received message with color: {message.ApplicationProperties["Color"]}, CorrelationId: {message.CorrelationId}");
        ResetColor();
    }

    private static async Task ReceiveMessagesAsync(ServiceBusClient client, string subscriptionName)
    {
        await using ServiceBusReceiver subscriptionReceiver = client.CreateReceiver(
            TopicName,
            subscriptionName,
            new ServiceBusReceiverOptions {ReceiveMode = ServiceBusReceiveMode.ReceiveAndDelete});

        WriteLine($"==========================================================================");
        WriteLine($"{DateTime.Now} :: Receiving Messages From Subscription: {subscriptionName}");
        int receivedMessageCount = 0;
        while (true)
        {
            var receivedMessage = await subscriptionReceiver.ReceiveMessageAsync(TimeSpan.FromSeconds(1));
            if (receivedMessage != null)
            {
                PrintReceivedMessage(receivedMessage);
                receivedMessageCount++;
            }
            else
            {
                break;
            }
        }

        WriteLine($"{DateTime.Now} :: Received '{receivedMessageCount}' Messages From Subscription: {subscriptionName}");
        WriteLine($"==========================================================================");
        await subscriptionReceiver.CloseAsync();
    }
}