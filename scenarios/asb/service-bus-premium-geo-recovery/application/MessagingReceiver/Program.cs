using Azure.Identity;
using Azure.Messaging.ServiceBus;

namespace MessagingReceiver
{
    public static class Program
    {
        private static async Task Main(string[] args)
        {
            Console.WriteLine("Messaging Receiver started.");

            const string queueName = "MyQueue";

            // Ref https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/servicebus/Azure.Messaging.ServiceBus#authenticating-with-azureidentity
            const string fullyQualifiedNamespace = "adt-sb-geodr-pri.servicebus.windows.net";
            await using var client = new ServiceBusClient(fullyQualifiedNamespace, new DefaultAzureCredential());

            // create the options to use for configuring the processor
            var options = new ServiceBusProcessorOptions
            {
                // By default or when AutoCompleteMessages is set to true, the processor will complete the message after executing the message handler
                // Set AutoCompleteMessages to false to [settle messages](https://docs.microsoft.com/en-us/azure/service-bus-messaging/message-transfers-locks-settlement#peeklock) on your own.
                // In both cases, if the message handler throws an exception without settling the message, the processor will abandon the message.
                AutoCompleteMessages = false,

                // I can also allow for multi-threading
                MaxConcurrentCalls = 8
            };

            // create a processor that we can use to process the messages
            await using ServiceBusProcessor processor = client.CreateProcessor(queueName, options);

            // configure the message and error handler to use
            processor.ProcessMessageAsync += MessageHandler;
            processor.ProcessErrorAsync += ErrorHandler;

            async Task MessageHandler(ProcessMessageEventArgs args)
            {
                string body = args.Message.Body.ToString();
                Console.WriteLine(body);

                // we can evaluate application logic and use that to determine how to settle the message.
                await args.CompleteMessageAsync(args.Message);
            }

            Task ErrorHandler(ProcessErrorEventArgs args)
            {
                // the error source tells me at what point in the processing an error occurred
                Console.WriteLine(args.ErrorSource);
                // the fully qualified namespace is available
                Console.WriteLine(args.FullyQualifiedNamespace);
                // as well as the entity path
                Console.WriteLine(args.EntityPath);
                Console.WriteLine(args.Exception.ToString());
                return Task.CompletedTask;
            }

            // start processing
            await processor.StartProcessingAsync();

            // since the processing happens in the background, we add a Console.ReadKey to allow the processing to continue until a key is pressed.
            Console.ReadKey();
        }
    }

}