using Microsoft.AspNetCore.Mvc;
using Play.Catalog.Service.Dtos;

namespace Play.Catalog.Service.Controllers;

[ApiController]
[Route("items")]
public class ItemsController : ControllerBase
{
    private static readonly List<ItemDto> items = new()
    {
        new ItemDto(Guid.NewGuid(), "Potion", "Restores a small amount of HP", 5, DateTimeOffset.UtcNow),
        new ItemDto(Guid.NewGuid(), "Antidote", "Cures poison", 7, DateTimeOffset.UtcNow),
        new ItemDto(Guid.NewGuid(), "Bronze sword", "Deals a small amount of damage", 20, DateTimeOffset.UtcNow)
    };

    [HttpGet]
    public IEnumerable<ItemDto> Get() { return items; }

    [HttpGet("{id}")]
    public ItemDto GetById(Guid id)
    {
        var item = items.SingleOrDefault(item => item.Id == id);
        return item;
    }

    [HttpPost]
    public ActionResult<ItemDto> Post(CreateItemDto createItemDto)
    {
        var item = new ItemDto(
                Guid.NewGuid(),
                createItemDto.Name,
                createItemDto.Description,
                createItemDto.Price,
                DateTimeOffset.UtcNow);
        items.Add(item);
        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    // PUT /items/{id}
    [HttpPut("{id}")]
    public IActionResult Put(Guid id, UpdateItemDto updatedItemDto)
    {
        var existingItem = items.SingleOrDefault(item => item.Id == id);
        var updatedItem = existingItem with
        {
            Name = updatedItemDto.Name,
            Description = updatedItemDto.Description,
            Price = updatedItemDto.Price
        };
        var index = items.FindIndex(existingItem => existingItem.Id == id);
        items[index] = updatedItem;

        return NoContent();
    }
}
