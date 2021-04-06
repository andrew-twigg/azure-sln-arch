# Publish and manage your APIs with Azure API Management

Azure API Management acts as a gateway between web APIs and the public internet.


- **API documentation** enables calling clients to quickly integrate their solutions. Allows you to quickly expose the structure of an API to calling clients through modern standards like Open API, supporting multiple versions.
- **Rate limiting access** to limit the rate at which clients request data.
    - helps maintain optimal response times for every client
    - rate limit as a whole or for individual clients
- **Health monitoring** allows you to view error responses and log files, and filter types of responses
- **Modern formats** like JSON
- **Connections to any API** lets you add disperate APIs into a single modern interface
- **Analytics** allows you to visualise APIs within the portal
- **Security** support authentication and authorization and integration with AAD

```sh
curl --header "Ocp-Apim-Subscription-Key: <key string>" https://<apim gateway>.azure-api.net/api/path

curl https://<apim gateway>.azure-api.net/api/path?subscription-key=<key string>
```
