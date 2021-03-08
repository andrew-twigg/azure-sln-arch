# Build Azure Resource Manager templates

## References

[Quickstart template galary](https://azure.microsoft.com/resources/templates)


## Learning objectives

- ARM and templates
- VM deployments with ARM
- ARM template customisations


## What is Azure Resource Manager?

- Interface for managing and organising cloud resources
- Organises resource group deployments


## What are ARM templates?

- Precisely defines all Resource Manager resources in a deployment
- Deploys in a single op
- <i>Declarative automation</i> JSON file. Define required resources, not how to create them.
- Resource Manager owns the responsibility of deploying the resources correctly


## Why use ARM templates?

- faster, more repeatable deployments
- <b>improved consistency</b>, a common language to describe deployments, regardless of the tool or SDK used to deploy the template, the structure, format and expressions remain the same.
- <b>help express complex deployments</b>, deploy multiple resources in the correct order. ARM maps out each resource and its dependent resources and creates dependent resources first.
- <b>templates are code</b>, IaC that can be shared, tested, versioned like other software.
- <b>promote reuse</b>, parameterised templateed enable you to create multiple varsions of the infra using same template.
- <b>linkable</b>, to make the templates modular. Compose templates to form a solution.


```sh
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "",
    "parameters": {  },
    "variables": {  },
    "functions": [  ],
    "resources": [  ],
    "outputs": {  }
}
```


