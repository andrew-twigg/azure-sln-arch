# Adding a custom role to a Management Group

Ref. [Azure custom roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles)

Prereqs - i already created a management group in the portal and assigned a Visual Studio sub to it.

## View the management group details

```sh
az account management-group show -n "VisualStudioEnterprise"

{
  "children": null,
  "details": {
    "parent": {
      "displayName": "Tenant Root Group",
      "id": "/providers/Microsoft.Management/managementGroups/18791e17-6159-4f52-a8d4-de814ca8284a",
      "name": "18791e17-6159-4f52-a8d4-de814ca8284a"
    },
    "updatedBy": "6fdc5b94-1baf-4b71-a3d1-f09392e5d382",
    "updatedTime": "2021-05-20T05:36:15.963495+00:00",
    "version": 1.0
  },
  "displayName": "Visual Studio Enterprise",
  "id": "/providers/Microsoft.Management/managementGroups/VisualStudioEnterprise",
  "name": "VisualStudioEnterprise",
  "roles": null,
  "tenantId": "18791e17-6159-4f52-a8d4-de814ca8284a",
  "type": "/providers/Microsoft.Management/managementGroups"
}

# List out the Virtual Machine roles available...
az role definition list --query "sort_by([?starts_with(roleName, 'Virtual')], &roleName)[*].{roleName:roleName, name:name, description:description}" -o table


```


