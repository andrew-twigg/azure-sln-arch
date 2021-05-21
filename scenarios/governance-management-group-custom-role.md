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

Virtual machine roles...

```sh
RoleName                             Name                                  Description
-----------------------------------  ------------------------------------  ------------------------------------------------------------------------------------------------------------------------------
Virtual Machine Administrator Login  1c0163c0-47e6-4577-8991-ea5c82e286e4  View Virtual Machines in the portal and login as administrator
Virtual Machine Contributor          9980e02c-c2be-4d73-94e8-173b1dc7cf3c  Lets you manage virtual machines, but not access to them, and not the virtual network or storage account they're connected to.
Virtual Machine User Login           fb879df8-f326-4884-b1cf-06f3ad86be52  View Virtual Machines in the portal and login as a regular user.
```

Contributor role...

```sh
az role definition list --name 'Virtual Machine Contributor'

[
  {
    "assignableScopes": [
      "/"
    ],
    "description": "Lets you manage virtual machines, but not access to them, and not the virtual network or storage account they're connected to.",
    "id": "/subscriptions/b70490c4-40b2-4066-afc9-05b797168001/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
    "name": "9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
    "permissions": [
      {
        "actions": [
          "Microsoft.Authorization/*/read",
          "Microsoft.Compute/availabilitySets/*",
          "Microsoft.Compute/locations/*",
          "Microsoft.Compute/virtualMachines/*",
          "Microsoft.Compute/virtualMachineScaleSets/*",
          "Microsoft.Compute/disks/write",
          "Microsoft.Compute/disks/read",
          "Microsoft.Compute/disks/delete",
          "Microsoft.DevTestLab/schedules/*",
          "Microsoft.Insights/alertRules/*",
          "Microsoft.Network/applicationGateways/backendAddressPools/join/action",
          "Microsoft.Network/loadBalancers/backendAddressPools/join/action",
          "Microsoft.Network/loadBalancers/inboundNatPools/join/action",
          "Microsoft.Network/loadBalancers/inboundNatRules/join/action",
          "Microsoft.Network/loadBalancers/probes/join/action",
          "Microsoft.Network/loadBalancers/read",
          "Microsoft.Network/locations/*",
          "Microsoft.Network/networkInterfaces/*",
          "Microsoft.Network/networkSecurityGroups/join/action",
          "Microsoft.Network/networkSecurityGroups/read",
          "Microsoft.Network/publicIPAddresses/join/action",
          "Microsoft.Network/publicIPAddresses/read",
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.RecoveryServices/locations/*",
          "Microsoft.RecoveryServices/Vaults/backupFabrics/backupProtectionIntent/write",
          "Microsoft.RecoveryServices/Vaults/backupFabrics/protectionContainers/protectedItems/*/read",
          "Microsoft.RecoveryServices/Vaults/backupFabrics/protectionContainers/protectedItems/read",
          "Microsoft.RecoveryServices/Vaults/backupFabrics/protectionContainers/protectedItems/write",
          "Microsoft.RecoveryServices/Vaults/backupPolicies/read",
          "Microsoft.RecoveryServices/Vaults/backupPolicies/write",
          "Microsoft.RecoveryServices/Vaults/read",
          "Microsoft.RecoveryServices/Vaults/usages/read",
          "Microsoft.RecoveryServices/Vaults/write",
          "Microsoft.ResourceHealth/availabilityStatuses/read",
          "Microsoft.Resources/deployments/*",
          "Microsoft.Resources/subscriptions/resourceGroups/read",
          "Microsoft.SqlVirtualMachine/*",
          "Microsoft.Storage/storageAccounts/listKeys/action",
          "Microsoft.Storage/storageAccounts/read",
          "Microsoft.Support/*"
        ],
        "dataActions": [],
        "notActions": [],
        "notDataActions": []
      }
    ],
    "roleName": "Virtual Machine Contributor",
    "roleType": "BuiltInRole",
    "type": "Microsoft.Authorization/roleDefinitions"
  }
]
```

Create a new operator role (defined in json file)...

```sh
az role definition create --role-definition governance-management-group-custom-role-vm-operator.json
az role definition list --query "sort_by([?starts_with(roleName, 'Virtual')], &roleName)[*].{roleName:roleName, name:name, description:description}" -o table

RoleName                             Name                                  Description
-----------------------------------  ------------------------------------  ------------------------------------------------------------------------------------------------------------------------------
Virtual Machine Administrator Login  1c0163c0-47e6-4577-8991-ea5c82e286e4  View Virtual Machines in the portal and login as administrator
Virtual Machine Contributor          9980e02c-c2be-4d73-94e8-173b1dc7cf3c  Lets you manage virtual machines, but not access to them, and not the virtual network or storage account they're connected to.
Virtual Machine Operator             fa40e5bd-2dca-4f0d-a597-4cec11ff5c66  Can monitor and restart virtual machines.
Virtual Machine User Login           fb879df8-f326-4884-b1cf-06f3ad86be52  View Virtual Machines in the portal and login as a regular user.
```


