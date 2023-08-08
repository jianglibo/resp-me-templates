## About tempate type.

Templates usually instance out new deployDefinition which can be deployed periodly or cronly. Some templates didn't instance out a new deployDefintion but only create something for you.

### tempalte which create a free subdomain name.

the template `free-sub-domain`, after instance it will get you this:

```json
{
  "domain_id": 331,
  "ip_address": "192.168.0.1",
  "domain_name": "8jg1afqfl1uh.free-ssl.me."
}
```

You need only to do this action once if you need only a free subdomain.

And this template will create a deployfinition for generate ssl certification.



