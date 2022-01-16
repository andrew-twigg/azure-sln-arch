// For the named parameters in Main.
// Ref. https://github.com/dotnet/command-line-api/blob/main/docs/Your-first-app-with-System-CommandLine-DragonFruit.md
using System.CommandLine;
using System.CommandLine.DragonFruit;

using Azure.Identity;
using Azure.Messaging.ServiceBus;

namespace MessagingSender
{
    public static class Program
    {
        static async Task Main(string sbPrimary="adt-sb-pri", string sbSecondary="adt-db-sec")
        {
            Console.WriteLine($"Messaging Sender started. Primary bus: {sbPrimary}, Secondary bus: {sbSecondary}");

            const string queueName = "MyQueue";

            string fullyQualifiedNamespacePri = $"{sbPrimary}.servicebus.windows.net";
            await using var client = new ServiceBusClient(fullyQualifiedNamespacePri, new DefaultAzureCredential());

            //// Create the sender
            //ServiceBusSender sender = client.CreateSender(queueName);

            //while (true)
            //{
            //    var messages = new Queue<ServiceBusMessage>();
            //    for (int i = 0; i < 1000; i++)
            //    {
            //        messages.Enqueue(new ServiceBusMessage(String.Format("Message {0}", i)));
            //    }

            //    // Send the message
            //    await sender.SendMessagesAsync(messages);
            //}
        }
    }
}