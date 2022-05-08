using System;
using System.Collections.Generic;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

using System.Threading.Tasks;
using System.Linq;
using Newtonsoft.Json;
using Microsoft.Azure.Cosmos;
using Shared;

namespace ChangeFeedFunctions
{
    public static class MaterializedViewFunction
    {
        // private static readonly string _endpointUrl = "<your-endpoint-url>";
        // private static readonly string _primaryKey = "<your-primary-key>";
        private static readonly string _connectionString = "";
        private static readonly string _databaseId = "StoreDatabase";
        private static readonly string _containerId = "StateSales";
        private static CosmosClient _client = new CosmosClient(_connectionString);


        [FunctionName("MaterializedViewFunction")]
        public static async Task Run([CosmosDBTrigger(
            databaseName: "StoreDatabase",
            collectionName: "CartContainerByState",
            ConnectionStringSetting = "DBConnection",
            CreateLeaseCollectionIfNotExists = true,
            LeaseCollectionName = "materializedViewLeases")]IReadOnlyList<Document> input,
            ILogger log)
        {
            var stateDict = new Dictionary<string, List<double>>();
            foreach (var doc in input)
            {
               var action = JsonConvert.DeserializeObject<CartAction>(doc.ToString());
            
               if (action.Action != ActionType.Purchased)
               {
                  continue;
               }
            
               if (stateDict.ContainsKey(action.BuyerState))
               {
                  stateDict[action.BuyerState].Add(action.Price);
               }
               else
               {
                  stateDict.Add(action.BuyerState, new List<double> { action.Price });
               }
            }

            var database = _client.GetDatabase(_databaseId);
            var container = database.GetContainer(_containerId);

            var tasks = new List<Task>();

            foreach (var key in stateDict.Keys)
            {
               var query = new QueryDefinition("select * from StateSales s where s.State = @state").WithParameter("@state", key);
            
               var resultSet = container.GetItemQueryIterator<StateCount>(query, requestOptions: new QueryRequestOptions() { PartitionKey = new Microsoft.Azure.Cosmos.PartitionKey(key), MaxItemCount = 1 });
            
               while (resultSet.HasMoreResults)
               {
                  var stateCount = (await resultSet.ReadNextAsync()).FirstOrDefault();
            
                  if (stateCount == null)
                  {
                     //todo: Add new doc code here
                     stateCount = new StateCount();
                     stateCount.State = key;
                     stateCount.TotalSales = stateDict[key].Sum();
                     stateCount.Count = stateDict[key].Count;
                  }
                  else
                  {
                     //todo: Add existing doc code here
                     stateCount.TotalSales += stateDict[key].Sum();
                     stateCount.Count += stateDict[key].Count;
                  }
            
                  //todo: Upsert document
                  log.LogInformation("Upserting materialized view document");
                  tasks.Add(container.UpsertItemAsync(stateCount, new Microsoft.Azure.Cosmos.PartitionKey(stateCount.State)));
               }
            }
            
            await Task.WhenAll(tasks);
        }
    }
}
