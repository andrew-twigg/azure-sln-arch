using System;
using Microsoft.Azure.WebJobs;
//using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace Thinktecture.MessageTransformer
{
    public static class MessageTransformer
    {
        [FunctionName("TransformMessage")]
        [return: ServiceBus("outbound", Connection = "OutboundQueue")]
        public static string Run(
            [ServiceBusTrigger("inbound", Connection = "InboundQueue")]
            string message,
            ILogger log)
        {
            if (string.IsNullOrWhiteSpace(message))
            {
                log.LogWarning("Bad Request: received NULL or empty message");
                throw new InvalidOperationException("Received invalid message");
            }
            log.LogInformation($"Received message '{message}' for transformation");

            var chars = message.ToCharArray();
            Array.Reverse(chars);
            var result = new string(chars);

            log.LogInformation($"Transformed message to '{result}'");
            return result;
        }
    }
}
