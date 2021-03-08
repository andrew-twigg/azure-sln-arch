# Explore Azure compute services

How to take advantage of virtualisation services in Azure compute, to scale quickly and efficiently to meet demands.


## Learning objectives

- Azure VMs
- Azure App Service
- Azure Container Instances
- Azure Kubernetes Service
- Azure Functions
- Windows Virtual Desktop


## Azure compute services

Azure compute is an on-demand computing service for running cloud-based applications. It provides on-demand compute rsources (disks, processors, memory, networking, and OSs).


### Virtual Machines

- Azure Virtual Machines
- Infrastructure as a Service (IaaS)
- Software emulations of physical computers
- Virtual processor, storage, memory, networking
- OS
- Accessible by RDP
- Flexibility with what software is running on the service


### Virtual machine scale sets

- Deploy and manage a set of identical VMs
- True autoscale
- No pre-provisioning required
- Build large-scale services targetting big compute, big data, containerised workloads
- Scale to meet demand
- Manual/automated scaling


### Containers and Kubernetes

- Container Instances
- Azure Kubernetes Service
- Deploy and manage containers
- Lightweight virtualised app environments
- Create/scale/stop dynamically
- Multi-instance hosting


### App Service

- Enterprise web, mobile, API apps
- Cross-platform
- Manual/autoscale
- PaaS


## When to use Azure VMs

- Flexibility to virtualisation without having to buy and maintain physical hardware.
- Rapid provisioning
- Scenarios
    - testing/development 
    - hosting apps in cloud
    - extending a data center into cloud
    - DR


### Scale VMs

- VM scale sets
    - create/manage group of identical load-based VMs
    - centrally manage, configure, and update a large number of VMs
    - supports HA applications
    - Autoscale
    - compute, big-data, container workloads

- Azure Batch
    - large scale parallel and high-performance computing (HPC) batch jobs
    - scale to tens, to thousands of VMs
    - Batch runs a job
        - start a pool of compute VMs
        - install apps and staging data
        - run jobs with tasks
        - identify failures
        - requeue work
        - scale down
    - Supercomputer level compute power


## When to use Azure Container Instances or Kubernetes Service

VMs are limited to a single OS per VM. If you want to run multiple instances of an app, potentially with multiple different runtime environments, on a single host machine then containers are a good choice. VM starting/snapshotting can be slow, containers are fast.


### Containers

- VMs virtualise the hardware, containers virtualise the OS
- Abracts away the host OS and infra requirements allowing containers to run side by side
- You don't manage an OS for a container
- Create, scale, stop dynamically
- lightweight
- Simplifies development
    - Development environment can look exactly like production environment
- Container cluster orchestration 
- Support microservices based architectures


### Azure Container Instances

- Fastest way to run a container in Azure 
- No need to manage VMs or adopt additional services
- PaaS container service


### Azure Kubernetes Service

- Complete orchestration service for containers with distributed architectures
- Management system for container based workload
- container management automation with an API
- manages placement of pods on kube nodes
- scales through pod autoscaling
- manages updates
    - schedule
    - update
    - rollback
- distributed perstistant volumes
- networking/loadbalancing/isolation/routing


## When to use Azure App Service

- Build and host web aps, backgroup jobs, mobile backends, RESTful APIs
- Minimal infra management
- Automatic scaling / HA
- Windows/Linux
- Automated deployments from GitHub, Azure DevOps, any Git repo with CD model
- PaaS
- Built in load balancing and traffic management


## When to use Azure Functions

- Serverless computing for abstraction of serversm event-driven scale and micro-billing
- No infrastructure management (just service provisioning)
- Execution context is transparent to code
- Code runs with HA
- Event driven scale to respond to incoming events 
    - Timers
    - HTTP
    - Queues
    - etc

## Logic Apps

- workflows (designer-first declarative)
- automate business processes composed from predefined logic blocks
- large collection of connectors and Enterprise Integration Pack to support B2B scenarios)
- Log Analytics


## When to use Windows Virtual Desktop

- User experience
    - Connect with any device over the internet
    - Native app on device or HTML5 web client
    - Session host VMs run near apps and services that connect to datacenter or cloud
    - Fast load times
        - user profiles are containerised using FSLogix
- Enhance security
- Simplified management
- Performance management
- Multi-session Windows 10 deployment

