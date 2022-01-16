using Azure.Identity;
using Azure.Messaging.ServiceBus;

namespace MessagingSender
{
    public static class Program
    {
        private static async Task Main(string[] args)
        {
            Console.WriteLine("Messaging Sender started.");

            const string queueName = "MyQueue";

            // Ref https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/servicebus/Azure.Messaging.ServiceBus#authenticating-with-azureidentity
            const string fullyQualifiedNamespace = "adt-sb-geodr.servicebus.windows.net";
            await using var client = new ServiceBusClient(fullyQualifiedNamespace, new DefaultAzureCredential());

            // Create the sender
            ServiceBusSender sender = client.CreateSender(queueName);

            while (true)
            {
                var messages = new Queue<ServiceBusMessage>();
                for (int i = 0; i < 1000; i++)
                {
                    messages.Enqueue(new ServiceBusMessage(String.Format("Message {0}", i)));
                }

                // Send the message
                await sender.SendMessagesAsync(messages);
            }
        }
    }
}
