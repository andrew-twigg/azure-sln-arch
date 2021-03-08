# Choose a compute provisioning solution for your application

Manual provisioning of compute resources requires administration, is a repetitive task, and is error prone.  

Manual implementation of a system with many servers is time consuming, requiring OS, software install, configuration, updates, on each VM. Might need to redeploy, example in DR scenario or new environments.


## Learning objectives

- Compute provisioning systems in Azure
- Provisioning platform choice based on requirements


## Custom scripts

- Downloads and runs a script on Azure VMs
- Useful for post-deployment config / software install
- Serve the script from local file server, GitHub, Azure Storage
- Script is downloaded and executed on the target machine
- Script is added via ARM template, PowerShell, or CLI

```sh
{
    "apiVersion": "2019-06-01",
    "type": "Microsoft.Compute/virtualMachines/extensions",
    "name": "[concat(variables('virtual machineName'),'/', 'InstallWebServer')]",
    "location": "[parameters('location')]",
    "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/',variables('virtual machineName'))]"
    ],
    "properties": {
        "publisher": "Microsoft.Compute",
        "type": "CustomScriptExtension",
        "typeHandlerVersion": "1.7",
        "autoUpgradeMinorVersion":true,
        "settings": {
            "fileUris": [
                "https://your-potential-file-location.com/your-script-file.ps1"
            ],
            "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File your-script-file.ps1"
       		 }
    	}
	}
}
```

## Desired State Configuration extensions

- Deal with complex installation procedures
- Define a state, rather than detailed manual instructions
- State configs can located in blob or internal storage

```sh
{
	"type": "Microsoft.Compute/virtualMachines/extensions",
	"name": "Microsoft.Powershell.DSC",
	"apiVersion": "2018-06-30",
	"location": "your-region",
	"dependsOn": [
		"[concat('Microsoft.Compute/virtualMachines/', parameters('virtual machineName'))]"
	],
	"properties": {
		"publisher": "Microsoft.Powershell",
		"type": "DSC",
		"typeHandlerVersion": "2.77",
		"autoUpgradeMinorVersion": true,
		"settings": {
			"configuration": {
				"url": "https://demo.blob.core.windows.net/iisinstall.zip",
				"script": "IisInstall.ps1",
				"function": "IISInstall"
			}
		},
		"protectedSettings": {
			"configurationUrlSasToken": "odLPL/U1p9lvcnp..."
		}
	}
}
```

## Chef

- Automates infra deployment and fit it into workflow, on-prem or cloud
- Handles 10,000 nodes (machines) at a time
- Typically runs as a service
- Recipes run commands to achieve a configuration

```sh
knife azurerm server create `
    --azure-resource-group-name rg-chefdeployment `
    --azure-storage-account store `
    --azure-vm-name chefvm `
    --azure-vm-size 'Standard_DS2_v2' `
    --azure-service-location 'eastus' `
    --azure-image-reference-offer 'WindowsServer' `
    --azure-image-reference-publisher 'MicrosoftWindowsServer' `
    --azure-image-reference-sku '2016-Datacenter' `
    --azure-image-reference-version 'latest' `
    -x myuser `
    -P yourPassword `
    --tcp-endpoints '80,3389' `
    --chef-daemon-interval 1 `
    -r "recipe[webserver]"
```

also via ARM

```sh
{
  "type": "Microsoft.Compute/virtualMachines/extensions",
  "name": "[concat(variables('virtual machineName'),'/', variables('virtual machineExtensionName'))]",
  "apiVersion": "2015-05-01-preview",
  "location": "[parameters('location')]",
  "dependsOn": [
    "[concat('Microsoft.Compute/virtualMachines/', variables('virtual machineName'))]"
  ],
  "properties": {
    "publisher": "Chef.Bootstrap.WindowsAzure",
    "type": "LinuxChefClient",
    "typeHandlerVersion": "1210.12",
    "settings": {
      "bootstrap_options": {
        "chef_node_name": "chef_node_name",
        "chef_server_url": "chef_server_url",
        "validation_client_name": "validation_client_name"
      },
      "runlist": "recipe[your-recipe]",
      "validation_key_format": "validation_key_format",
      "chef_service_interval": "chef_service_interval",
      "bootstrap_version": "bootstrap_version",
      "bootstrap_channel": "bootstrap_channel",
      "daemon": "service"
    },
    "protectedSettings": {
      "validation_key": "validation_key",
      "secret": "secret"
    }
  }
}
```

## Terraform

- Open-source IaC tool
- Hashicorp Configuration Language (HCL), or JSON
- Run from local or Azure
- Cross-cloud

```sh
# Configure the Microsoft Azure as a provider
provider "azurerm" {
    subscription_id = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    client_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    client_secret   = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    tenant_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

# Create a resource group
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
}
# Create the virtual machine
resource "azurerm_virtual_machine" "myterraformvirtual machine" {
    name                  = "myvirtual machine"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    virtual machine_size  = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvirtual machine"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3Nz{snip}hwhaa6h"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags = {
        environment = "Terraform Demo"
    }
}
```

## Azure Automatioon stage configuration

- service to manage DSC configs and deployments across nodes
- VMs and on-prem
- Supports other cloud providers
- In the Azure Portal


## ARM templates

- Define resources though object notation
- Ensure consistent deployment
- Idempotent

```sh
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2018-10-01",
  "name": "[variables('virtual machineName')]",
  "location": "[parameters('location')]",
  "dependsOn": [
    "[resourceId('Microsoft.Storage/storageAccounts/', variables('storageAccountName'))]",
    "[resourceId('Microsoft.Network/networkInterfaces/', variables('nicName'))]"
  ],
  "properties": {
    "hardwareProfile": {
      "virtual machinesize": "Standard_A2"
    },
    "osProfile": {
      "computerName": "[variables('virtual machineName')]",
      "adminUsername": "[parameters('adminUsername')]",
      "adminPassword": "[parameters('adminPassword')]"
    },
    "storageProfile": {
      "imageReference": {
        "publisher": "MicrosoftWindowsServer",
        "offer": "WindowsServer",
        "sku": "[parameters('windowsOSVersion')]",
        "version": "latest"
      },
      "osDisk": {
        "createOption": "FromImage"
      },
      "dataDisks": [
        {
          "diskSizeGB": 1023,
          "lun": 0,
          "createOption": "Empty"
        }
      ]
    },
    "networkProfile": {
      "networkInterfaces": [
        {
          "id": "[resourceId('Microsoft.Network/networkInterfaces',variables('nicName'))]"
        }
      ]
    },
    "diagnosticsProfile": {
      "bootDiagnostics": {
        "enabled": true,
        "storageUri": "[reference(resourceId('Microsoft.Storage/storageAccounts/', variables('storageAccountName'))).primaryEndpoints.blob]"
      }
    }
  }
}
```


# Native Azure solutions

- problem definition
- size of infrastructure
- outcome goal

Metrics

- ease of setup
- management
- interop
- config language
- limitations and drawbacks


## Custom scripts

Good for small configs after provisioning, and to add or update some apps on a target quickly. Imperative for ad-hoc cross-plat scripting.

- <b>ease of setup</b>. Built into Azure, so easy.
- <b>management</b>. More difficult as infra grows.
- <b>interop</b>. Extends from ARM templates, PowerShell, CLI.
- <b>config language</b>. PowerShell and bash.
- <b>limitations and drawbacks</b>. Not suitable in long deployment times (1.5 h), or when need reboots.


## DSC

- <b>ease of setup</b>. Easy to read, update, and store. Define what you want, author doesn't need to know how that state is achieved.
- <b>management</b>. Democratises configuration management across servers.
- <b>interop</b>. Used with Azure Automation State Configuration. Portal, PowerShell and ARM.
- <b>config language</b>. PowerShell.
- <b>limitations and drawbacks</b>. Can only use PowerShell. Using without Azure Automation State Configuration means you have to take care of your own orchestration and management.


## Automation State Configuration

- <b>ease of setup</b>. Requires familiarity with Azure portal.
- <b>management</b>. Automatic VM management.
- <b>interop</b>. Works with cloud/on-prem VMs automatically.
- <b>config language</b>. PowerShell.
- <b>limitations and drawbacks</b>. Only PowerShell.


## ARM templates

- <b>ease of setup</b>. Easy to create. Large community to pull from. Native extraction feature in portal.
- <b>management</b>. Manage JSON files.
- <b>interop</b>. CLI, Azure Portal, PowerShell, Terraform.
- <b>config language</b>. JSON.
- <b>limitations and drawbacks</b>. JSON strict syntax and grammar. Requirement to know all the resource providers can be onerous.


# Third-party solutions

## Chef

- <b>ease of setup</b>. Requires a Chef server machine. Hosted Chef gets you running faster.
- <b>management</b>. Ruby based domain-specific language. Could require a Ruby developer to manage the config.
- <b>interop</b>. Chef server Linux/Unix only. Client can run on Windows.
- <b>config language</b>. Ruby-based.
- <b>limitations and drawbacks</b>. Language takes time to learn if you're not on a Ruby stack.


## Terraform

- <b>ease of setup</b>. ??.
- <b>management</b>. Easy to manage.
- <b>interop</b>. Azure, AWS, Google Cloud Platform.
- <b>config language</b>. Hashicorp (HCL). Can use JSON.
- <b>limitations and drawbacks</b>. Might not support all Azure resource types.


## Example

Provision a VM with ARM template and DSC.

```sh
git clone https://github.com/MicrosoftDocs/mslearn-choose-compute-provisioning.git

cd mslearn-choose-compute-provisioning
vim Webserver.ps1
```

DSC...

```sh
Configuration Webserver
{
    param ($MachineName)

    Node $MachineName
    {
        #Install the IIS Role
        WindowsFeature IIS
        {
            Ensure = "Present"            Name = "Web-Server"
        }

        #Install ASP.NET 4.5
        WindowsFeature ASP
        {
            Ensure = "Present"
            Name = "Web-Asp-Net45"
        }

            WindowsFeature WebServerManage
mentConsole
        {
            Name = "Web-Mgmt-Console"
            Ensure = "Present"
        }
    }
}
```

Validate...

```sh
az deployment group validate \
    --resource-group learn-62326144-343e-463d-95b1-682881607ab0 \
    --template-file template.json \
    --parameters vmName=hostVM1 adminUsername=serveradmin
```

Deploy...

```sh
az deployment group create \
    --resource-group learn-62326144-343e-463d-95b1-682881607ab0 \
    --template-file template.json \
    --parameters vmName=hostVM1 adminUsername=serveradmin
```
