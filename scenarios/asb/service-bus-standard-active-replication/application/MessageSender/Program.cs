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

            const string queueName = "myqueue";

            await using var clientPri = new ServiceBusClient($"{sbPrimary}.servicebus.windows.net", new DefaultAzureCredential());
            await using var clientSec = new ServiceBusClient($"{sbSecondary}.servicebus.windows.net", new DefaultAzureCredential());

            // Create the sender
            ServiceBusSender senderPri = clientPri.CreateSender(queueName);
            ServiceBusSender senderSec = clientSec.CreateSender(queueName);

            Console.WriteLine("\nSending messages to primary and secondary queues...\n");

            // TODO: Error handling?

            for (int i = 0; i < 5; i++)
            {
                var m1 = new ServiceBusMessage("Message" + i)
                {
                    MessageId = i.ToString(),
                    TimeToLive = TimeSpan.FromMinutes(2.0)
                };

                var m2 = new ServiceBusMessage("Message" + i)
                {
                    MessageId = i.ToString(),
                    TimeToLive = TimeSpan.FromMinutes(2.0)
                };

                var exceptionCount = 0;

                var t1 = senderPri.SendMessageAsync(m1);
                var t2 = senderSec.SendMessageAsync(m2);

                // collect result for primary queue
                try
                {
                    await t1;
                    Console.WriteLine("Message {0} sent to primary queue: Body = {1}", m1.MessageId, m1.Body.ToString());
                }
                catch (Exception e)
                {
                    Console.WriteLine("Unable to send message {0} to primary queue: Exception {1}", m1.MessageId, e);
                    exceptionCount++;
                }

                // collect result for secondary queue
                try
                {
                    await t2;
                    Console.WriteLine("Message {0} sent to secondary queue: Body = {1}", m2.MessageId, m2.Body.ToString());
                }
                catch (Exception e)
                {
                    Console.WriteLine("Unable to send message {0} to secondary queue: Exception {1}", m2.MessageId, e);
                    exceptionCount++;
                }
            }

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