# Control and organise Azure resources with Azure Resource Manager

Using Azure Resource Manager to organise resources, enforcestandards, and protect critical assets from deletion.


# Learning objectives

- Organise Azure resources using resource groups
- Use tags to organise resources
- Apply policies to enforce standards in your Azure environments
- Use resource locks to protect critical Azure resources from accidental deletion


## Principles of resource groups

- Fundamental element of the Azure platform
- Logical container for resources on Azure
- All resources must be in a resource group and a resource can only be a member of one resource group
- Exist to help manage and organise resources

### Organising principles

- <b>For auth</b>, RGs are a scope of RBAC. You can organise by who needs to administer them.
- <b>For life cycle</b>, group resources related by life cycle, ex. environments.
- <b>For billing</b>


## Use tagging to organise resources

- A way of adding custom info to a resource
- have upto 50
- name limited to 512
- automatically add/enforce tags on resources
- use tags to group for billing

```sh
az resource tag --tags Department=Finance \
    --resource-group msftlearn-core-infrastructure-rg \
    --name msftlearn-vnet1 \
    --resource-type "Microsoft.Network/virtualNetworks"
```


## Use policies to enforce standards

Policies help enforce standards in the Azure environment.

Azure Policy is a service used to create, assign, and manage policies. These policies aply and enforce rules that resources need to follow. Can be evaluated against existing resources to give visibility of compliance.

- allow specific types of resources to be created
- enforce specific regions
- naming conventions
- tags


## Secure resources with role-based access control

## Use resource locks to protect resources

