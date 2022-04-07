using Azure;
using Azure.Data.Tables;

using Microsoft.AspNetCore.Mvc;

namespace ApiApp.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;
    private readonly TableClient tableClient;

    public WeatherForecastController(ILogger<WeatherForecastController> logger, TableClient tableClient)
    {
        _logger = logger;
        this.tableClient = tableClient;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        var entities = this.tableClient.Query<TableEntity>();
        var forecastModels = entities.Select(e => MapTableEntityToWeatherForecast(e));

        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }

    [HttpGet("{time}")]
    public async Task<ActionResult<WeatherForecast>> GetByTimeAsync(DateTime time)
    {
        throw new NotImplementedException();

        //var item = await itemsRepository.GetAsync(id);

        //if (item == null)
        //{
        //    return NotFound();
        //}

        //return item.AsDto();
    }

    [HttpPost]
    public async Task<ActionResult<WeatherForecast>> PostAsync(WeatherForecast forecast)
    {
        var entity = new TableEntity
        {
            PartitionKey = forecast.StationName,
            RowKey = forecast.Date.ToString()
        };

        entity["Temperature"] = forecast.TemperatureC;
        entity["Summary"] = forecast.Summary;

        // Row key isn't valid
        await this.tableClient.AddEntityAsync(entity);

        return CreatedAtAction(nameof(GetByTimeAsync), new { time = forecast.Date }, forecast);

        //        var item = new Item
        //        {
        //            Name = createItemDto.Name,
        //            Description = createItemDto.Description,
        //            Price = createItemDto.Price,
        //            CreateDate = DateTimeOffset.UtcNow
        //        };
        //
        //        await itemsRepository.CreateAsync(item);
        //
        //        await publishEndpoint.Publish(new CatalogItemCreated(item.Id, item.Name, item.Description));
        //
        //        return CreatedAtAction(nameof(GetByIdAsync), new { id = item.Id }, item);
    }

    private WeatherForecastModel MapTableEntityToWeatherForecast(TableEntity entity)
    {
        var forecast = new WeatherForecastModel
        {
            StationName = entity.PartitionKey,
            ForecastDate = entity.RowKey,
            Timestamp = entity.Timestamp,
            Etag = entity.ETag.ToString()
        };

        //var measurements = entity.Keys.Where(key => !EXCLUDE_TABLE_ENTITY_KEYS.Contains(key));
        foreach (var item in entity.Keys)
        {
            forecast[item] = entity[item];
        }

        return forecast;

        //return new WeatherForecast
        //{
        //    StationName = "001",
        //    Date = DateTime.Now,
        //    TemperatureC = Random.Shared.Next(-20, 55),
        //    Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        //};
    }
}

internal class WeatherForecastModel
{
    // Captures all of the weather data properties -- temp, humidity, wind speed, etc
    private Dictionary<string, object> _properties = new Dictionary<string, object>();

    public string StationName { get; set; }
    public string ForecastDate { get; set; }
    public DateTimeOffset? Timestamp { get; set; }
    public string Etag { get; set; }
    public object this[string name]
    {
        get => _properties.ContainsKey(name) ? _properties[name] : null;
        set => _properties[name] = value;
    }
}