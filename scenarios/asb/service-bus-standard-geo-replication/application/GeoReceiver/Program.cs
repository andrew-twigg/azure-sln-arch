// For the named parameters in Main.
// Ref. https://github.com/dotnet/command-line-api/blob/main/docs/Your-first-app-with-System-CommandLine-DragonFruit.md
using System.CommandLine;
using System.CommandLine.DragonFruit;

using Azure.Identity;
using Azure.Messaging.ServiceBus;

namespace GeoReceiver
{
    public static class Program
    {
        static async Task Main(string sbPrimary="adt-sb-pri", string sbSecondary="adt-db-sec")
        {
            Console.WriteLine($"Messaging receiver started. Primary bus: {sbPrimary}, Secondary bus: {sbSecondary}");

            const string queueName = "myqueue";

            await using var clientPri = new ServiceBusClient($"{sbPrimary}.servicebus.windows.net", new DefaultAzureCredential());
            await using var clientSec = new ServiceBusClient($"{sbSecondary}.servicebus.windows.net", new DefaultAzureCredential());

            // create the options to use for configuring the processor
            var options = new ServiceBusProcessorOptions
            {
                // By default or when AutoCompleteMessages is set to true, the processor will complete the message after executing the message handler
                // Set AutoCompleteMessages to false to [settle messages](https://docs.microsoft.com/en-us/azure/service-bus-messaging/message-transfers-locks-settlement#peeklock) on your own.
                // In both cases, if the message handler throws an exception without settling the message, the processor will abandon the message.
                AutoCompleteMessages = false,

                // I can also allow for multi-threading
                MaxConcurrentCalls = 1
            };

            // create a processor that we can use to process the messages
            await using ServiceBusProcessor processorPri = clientPri.CreateProcessor(queueName, options);
            await using ServiceBusProcessor processorSec = clientSec.CreateProcessor(queueName, options);

            // TODO: How synchronise the receivers?
            var receivedMessageList = new List<string>();
            var receivedMessageListLock = new object();

            processorPri.ProcessMessageAsync += MessageHandler;
            processorSec.ProcessMessageAsync += MessageHandler;

            processorPri.ProcessErrorAsync += ErrorHandler;
            processorSec.ProcessErrorAsync += ErrorHandler;

            async Task MessageHandler(ProcessMessageEventArgs args)
            {
                // Duplicate message detection.
                bool duplicate;
                lock (receivedMessageListLock)
                {
                    duplicate = receivedMessageList.Remove(args.Message.MessageId);
                    if (duplicate)
                    {
                        Console.WriteLine($"{args.Message.Body} (duplicate detected)");
                    }
                    else
                    {
                        receivedMessageList.Add(args.Message.MessageId);
                        if (receivedMessageList.Count > 256)
                        {
                            receivedMessageList.RemoveAt(0);
                        }

                        // Handle the message
                        Console.WriteLine($"{args.Message.Body}");
                    }
                }

                // we can evaluate application logic and use that to determine how to settle the message.
                await args.CompleteMessageAsync(args.Message);
            }

            Task ErrorHandler(ProcessErrorEventArgs args)
            {
                // the error source tells me at what point in the processing an error occurred
                //Console.WriteLine(args.ErrorSource);
                // the fully qualified namespace is available
                //Console.WriteLine(args.FullyQualifiedNamespace);
                // as well as the entity path
                //Console.WriteLine(args.EntityPath);
                //Console.WriteLine(args.Exception.ToString());
                return Task.CompletedTask;
            }

            // start processing
            await processorPri.StartProcessingAsync();
            await processorSec.StartProcessingAsync();

            // since the processing happens in the background, we add a Console.ReadKey to allow the processing to continue until a key is pressed.
            Console.ReadKey();
        }
    }
}
