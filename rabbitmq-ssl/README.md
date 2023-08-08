## Template Rabbitmq-ssl

This template will install a rabbmitmq server on your server. Using nginx to proxy the webui and the amqp.

### What's created?

* a domain like ux8s8u.free-ssl.me
* a Domain object in our system which will update the ssl certification automatically.
* and a running rabbitmq server on your server.

### after using this templat.
![instance result](./images/instance-result.png)

The settings of the free-sub-domain-cert:

```json
{
  "domain_id": 333,
  "ip_address": "192.168.0.1",
  "domain_name": "n0geh90bq7jx.free-ssl.me."
}
```
change the ip_address to your server.

the settings of the rabbitmq-ssl:

```json
{
  "connection": {
    "host": "linux-users.koreacentral.cloudapp.azure.com", // change this to the subdomain showed above.
    "port": 22,
    "user": "azureuser", // adjust the name.
    "workingdir": "/home/azureuser",
    "sudo": true,
    "exec": false,
    "sshkey_id": 45 // copy the sshkey's public key to your server.
  },
  "mustache": {
    "scopes": {
      "ssl_certificate": "/opt/certs/fullchain.cer",
      "ssl_certificate_key": "/opt/certs/rabbitmq.key",
      "sitename": "site.name",
      "rabbitmqAdminName": "rabbitmqAdminName",
      "rabbitmqAdminPassword": "rabbitmqAdminPassword"
    },
    "templates": [
      {
        "template": "rabbitmq-proxy-5671.conf",
        "scopes": {}
      },
      {
        "template": "rabbitmq-proxy-15672.conf",
        "scopes": {}
      },
      {
        "template": "setup-nginx.sh",
        "scopes": {}
      },
      {
        "template": "setup-rabbitmq.sh",
        "scopes": {}
      }
    ]
  }
}
```