// For the named parameters in Main.
// Ref. https://github.com/dotnet/command-line-api/blob/main/docs/Your-first-app-with-System-CommandLine-DragonFruit.md
using System.CommandLine;
using System.CommandLine.DragonFruit;

using Azure.Identity;
using Azure.Messaging.ServiceBus;

namespace SenderPassiveReplication
{
    /// <summary>
    /// Passive replication sender.
    /// </summary>
    public static class Program
    {
        static async Task Main(string sbPrimary="adt-sb-pri", string sbSecondary="adt-db-sec")
        {
            Console.WriteLine($"Messaging Sender started. Primary bus: {sbPrimary}, Secondary bus: {sbSecondary}");

            const string queueName = "myqueue";

            await using var clientActive = new ServiceBusClient($"{sbPrimary}.servicebus.windows.net", new DefaultAzureCredential());
            await using var clientBackup = new ServiceBusClient($"{sbSecondary}.servicebus.windows.net", new DefaultAzureCredential());

            // Create the sender
            var activeSender = clientActive.CreateSender(queueName);
            var backupSender = clientBackup.CreateSender(queueName);

            Console.WriteLine("\nSending messages to primary or secondary queues...\n");

            object swapMutex = new();

            for (int i = 1; i <= 500; i++)
            {
                var message = new ServiceBusMessage("Message" + i)
                {
                    MessageId = i.ToString(),
                    TimeToLive = TimeSpan.FromMinutes(2.0)
                };
                var m1 = message;

                try
                {
                    await SendMessage(m1);
                }
                catch (Exception e)
                {
                    Console.WriteLine("Unable to send to primary or secondary queue: Exception {0}", e);
                }
            }

            async Task SendMessage(ServiceBusMessage m1, int maxSendRetries = 10)
            {
                while (true)
                {
                    // TODO: How do we clone the message? Is it important?
                    try
                    {
                        await activeSender.SendMessageAsync(m1);
                        return;
                    }
                    catch
                    {
                        if (--maxSendRetries <= 0)
                        {
                            throw;
                        }

                        lock (swapMutex)
                        {
                            var c = activeSender;
                            activeSender = backupSender;
                            backupSender = c;
                        }
                        //m1 = m2.Clone(); 
                    }
                }
            }
        }
    }
}