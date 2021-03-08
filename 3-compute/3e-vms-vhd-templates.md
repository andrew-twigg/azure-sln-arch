# Deploy Azure virtual machines from VHD templates

Standardise and automate virtual machine deployments to minimise manual config, variance and errors.

Create customised images, generalise imagesm and create specialised images from generalised versions. Deploy VM using these images.


## Learning objectives

- Ways to create specialised VHD
- Create virtual machine from an existing managed disk
- Create virtual machine image
- Create virtual machine from an existing virtual machine image


## What is a VHD?

- Conceptually similar to a physical disk
- Not physical hardware, a virtual file in Azure
- HA, 99.999 available.
- Physically secure, stored in cloud rather than a device on prem. Azure security to audit changes made to a VHD. Managed disks are encrypted. 
- Durable
- Scalable, create many VMs from same VHDs simultaniously with minimal contention
- Cost and performance range from dedicated SSDs to low cost VHDs, to meet your requirements.


## What is a VM image?

- Template from which to create VHDs to run a VM
- VHDs for a VM contain a preconfigured version of an OS.


## Generalised image

- Create using Hyper-V, first creating a blank virtual disk and then create a VM with the disk, then install the software
- Customise an Azure Marketplace image which proveds base functionality, add your own software and OS updates
- Save new image as a set if VHDs. Have to reset these back to default using Sysprep or waagent.
    - VM host name
    - creds
    - log files
    - security identifiers for various OS services


## Specialised Virtual Image

- Copy of a live VM after it has reached a specific state
- Configured OS + software + user accounts + DBs etc.
- Use as a backup, point in time.


# Example

- Create a custom image from a VM
- Use it to create new VM instances


```sh
az configure --defaults group=learn-da4caf58-1cb6-4b78-a2f2-910ce6469a5e

az vm create \
    --name MyUbuntuVM \
    --image UbuntuLTS \
    --generate-ssh-keys

az vm open-port \
    --name MyUbuntuVM \
    --port 80

az vm extension set \
    --publisher Microsoft.Azure.Extensions \
    --name CustomScript \
    --vm-name MyUbuntuVM \
    --settings '{"commandToExecute":"apt-get -y update && apt-get -y install nginx && hostname > /var/www/html/index.html"}'


echo http://$(az vm list-ip-addresses \
             --name MyUbuntuVM \
             --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
             --output tsv)
```

Generalise the VM

```sh
# Connect
ssh -o StrictHostKeyChecking=no 23.99.83.128

# Prep
sudo waagent -deprovision+user

WARNING! The waagent service will be stopped.
WARNING! Cached DHCP leases will be deleted.
WARNING! root password will be disabled. You will not be able to login as root.
WARNING! /etc/resolv.conf will NOT be removed, this isa behavior change to earlier versions of Ubuntu.
WARNING! andrew account and entire home directory willbe deleted.
Do you want to proceed (y/n)
```

```sh
exit
```

```sh
az vm deallocate --name MyUbuntuVM
az vm generalize --name MyUbuntuVM
az image create \
    --name MyVMIMage \
    --source MyUbuntuVM
```

Create a virtual machine

```sh
az vm create \
    --name MyVMFromImage \
    --computer-name MyVMFromImage \
    --image MyVMImage \
    --admin-username azureuser \
    --generate-ssh-keys
az vm extension set \
    --publisher Microsoft.Azure.Extensions \
    --name CustomScript \
    --vm-name MyVMFromImage \
    --settings '{"commandToExecute":"hostname > /var/www/html/index.html"}'
az vm open-port \
    --name MyVMFromImage \
    --port 80

echo http://$(az vm list-ip-addresses \
    --name MyVMFromImage \
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)
```
