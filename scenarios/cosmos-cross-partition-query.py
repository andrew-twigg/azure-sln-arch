import uuid
from azure.cosmos import exceptions, CosmosClient, PartitionKey

endpoint = 'https://adt-co-12990.documents.azure.com:443/'
key = '<deleted>'

client = CosmosClient(endpoint, key)
database_name = 'Products'

database_name = "Products"
database = client.create_database_if_not_exists(id=database_name)

container_name = "Clothing"
container = database.create_container_if_not_exists(
    id=container_name,
    partition_key=PartitionKey(path="/productId"),
    offer_throughput=1000)


def get_products():
    products = [{
        'id': str(uuid.uuid4()),
        'productId': '1',
        'someState': '10'
    }, {
        'id': str(uuid.uuid4()),
        'productId': '1',
        'someState': '15'
    }, {
        'id': str(uuid.uuid4()),
        'productId': '2',
        'someState': '10'
    }, {
        'id': str(uuid.uuid4()),
        'productId': '3',
        'someState': '15'
    }]
    return products


for product in get_products():
    container.create_item(body=product)

query = "SELECT * FROM c WHERE c.someState IN ('10')"

# Disabling cross partition query results in a BadRequest exception.
items = list(
    container.query_items(query=query, enable_cross_partition_query=True))

for item in items:
    print(item)
