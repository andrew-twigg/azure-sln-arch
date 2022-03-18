using System;
using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.Configuration;
using System.Threading;

namespace Thinktecture.Publisher
{
    public static class Program
    {
        static async Task Main(string[] args)
        {
            var config = new ConfigurationBuilder().AddEnvironmentVariables().Build();
            var connectionString = config.GetValue<string>("AzureServiceBus");
            var builder = new ServiceBusConnectionStringBuilder(connectionString);
            var client = new QueueClient(builder, ReceiveMode.PeekLock);
            while (true)
            {
                await PublishMessageAsync(client);
                Thread.Sleep(1000);
            }
        }

        static async Task PublishMessageAsync(QueueClient client)
        {
            var message = $"Thinktecture sample message generated at {DateTime.Now.ToLongTimeString()}";
            await client.SendAsync(new Message(System.Text.Encoding.UTF8.GetBytes(message)));
            Console.WriteLine("Message published to Azure Service Bus queue");
        }
    }
}