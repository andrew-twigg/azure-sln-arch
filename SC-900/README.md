# Exam SC-900: Microsoft Security, Compliance, and Identity Fundamentals

- AAD
- Azure
- M365
- Principals

## References

- [Exam SC-900: Microsoft Security, Compliance, and Identity Fundamentals](https://docs.microsoft.com/en-us/learn/certifications/exams/sc-900)

## Skills Measured

### Describe the Concepts of Security, Compliance, and Identity (5-10%)

Describe security methodologies
- [x] describe the Zero-Trust methodology
    - assume compromise
    - trust nothing, verify everything
    - authentication and authorization
    - least privilege
        - JIT (just in time) windows for elevations
        - JEA (just enough admin)
    - assume breach
        - segment
        - encrypt
        - detect threats
- [x] describe the shared responsibility model

|                               | On-prem  | IaaS       | PaaS      | SaaS      |
| ----------------------------- | :-----:  | :--:       | :--:      | :--:      |
| Information + Data            | customer | customer   | customer  | customer  |
| Devices                       | customer | customer   | customer  | customer  |
| Accounts                      | customer | customer   | customer  | customer  |
| Identity and directory infra  | customer | customer   | shared    | shared    |
| Application                   | customer | customer   | shared    | cloud     |
| Network controls              | customer | customer   | shared    | cloud     |
| OS                            | customer | customer   | cloud     | cloud     |
| Hosts                         | customer | cloud      | cloud     | cloud     |
| Network                       | customer | cloud      | cloud     | cloud     |
| Datacenter                    | customer | cloud      | cloud     | cloud     |


- [x] define defense in depth
    - physical
    - identity
        - user, application, device
    - perimeter, DDoS etc
    - network
    - compute
    - application
    - data encryption
        - classification
    - device
        - monitoring

**C**onfidentiality
**I**ntegrity
**A**vailability


Describe security concepts
- [x] describe common threats
    - data breach
    - identity attack
        - dictionary attack. Azure AD Smart Lockout
        - phishing attack 
        - spear phishing
    - ransomware
    - DDoS
- [x] describe encryption
    - symmetric, shared key, very efficient for large scale encryption
    - asymmetric, public/private key encryption
 
Describe Microsoft Security and compliance principles (six)
- [x] describe Microsoft's privacy principles
    - Control
        - customer in control of privacy
        - dials and controls
        - how customer wants data to be used
    - Transparent
        - not confusing
        - doesn't require discovery
    - Security
        - where there is data, ensure its protected
    - Strong legal protection
        - respecting local laws
        - fighting for privacy
    - No content based target
        - don't use the data for targetting like advertising 
    - Benefits to you
        - benefits to customer to enhance the experience
- [x] describe the offerings of the [service trust portal](https://servicetrust.microsoft.com)
    - audit reports across SOC, FedRAMP, ISO 27001, PCI/DSS
    - Compliance Manager gives you compliance score and breakdown
    - [Trust Documents blueprints](https://servicetrust.microsoft.com/ViewPage/BlueprintLegacy)
    - [Trust Center](https://www.microsoft.com/en-gb/trust-center)
    - [Compliance offerings](https://docs.microsoft.com/en-GB/compliance/regulatory/offering-home?view=o365-worldwide)
     


### Describe the capabilities of Microsoft Identity and Access Management Solutions (25-30%)

Define identity principles/concepts
- [ ] define identity as the primary security perimeter
- [ ] define authentication
    - Who i am
- [ ] define authorization
    - What i can do
- [ ] describe what identity providers are
    
- [ ] describe what Active Directory is
    - users, groups, devices
    - 
- [ ] describe the concept of Federated services
- [ ] define common Identity Attacks

Describe the basic identity services and identity types of Azure AD
- [x] describe what Azure Active Directory is
    - cloud based identity provider
    - modern identity provider (OIDC, OAuth2, SAML)
- [x] describe Azure AD identities (users, devices, groups, service principals/applications)
    - synchronised users
    - cloud native accounts
    - guests (partner orgs that you want to colaborate with, MSA, gmail, ...)
    - service principals
    - app registrations
    - managed identities
    - groups (assigned or dynamic), for assigning applications licences and roles etc
    - devices
        - joined (WIN10), auth with AAD account
        - registered, personal. WIN10, IOS, droid, macos, signin with personal accounts
        - hybrid
- [ ] describe what hybrid identity is
- [ ] describe the different external identity types (Guest Users)

Describe the authentication capabilities of Azure AD
- [ ] describe the different authentication methods
    - authenticator app
    - H4B
    - MFA
- [x] describe self-service password reset
- [x] describe password protection and management capabilities
    - authentication methods password protection configuration
    - lockout threshold, how many failed signins allowed before lockout
    - lockout duration
    - custom banned passwords
- [x] describe Multi-factor Authentication
    - Something i know (password, pin)
    - Something i have (laptop, phone, token)
    - Something i am (biometric - facial scan, thumbprint)
- [x] describe Windows Hello for Business
    - H4B
    - beyond passwords
    - uses the Trusted Platform Module (TPM) on the laptop, containing the private key
    - something i know, to unlock it
    - something i have, unlocking the device

Describe access management capabilities of Azure AD
- [x] describe what conditional access is
    - for driving MFA
    - policies, driving MFA if there's an elevated risk level
    - P1/P2 licensing
    - M365 per user config
    - Free, you get security defaults    
- [x] describe uses and benefits of conditional access
    - uses **signals**, to make **decisions**, and **enforce** organisational policy.
        - signals: users and groups, network locations, applications, devices, risk
        - decisions: block access, require MFA, require compliant device, password change, terms of use
    - heart of the identity driven control plane
    - two primary goals
        - allow users to be productive wherever and whenever
        - protect the orgs assets 
- [ ] describe the benefits of Azure AD roles

Describe the identity protection & governance capabilities of Azure AD
- [x] describe what identity governance is
    - capabilities to ensure that the right people have the right access to the resources
    - across employees, business partners and vendors, services and apps, on-prem and in cloud
        - govern identity lifecycle
        - govern access lifecycle
        - secure privileged access and admin
    - specifically
        - which users should have access
        - what are they using access for
        - are there effective org controls for access management
        - auditing effectiveness
- [ ] describe what entitlement management and access reviews is 
    - P2 feature, review periodically app assignments, role assignments, group assignments
- [x] describe the capabilities of PIM
    - manage, control and monitor access to important resources in your org
    - elevate up for a period of time (JIT)
    - have the role for a fixed time (JEA)
    - roles assigned outside of PIM are perminent until someone removes 
- [x] describe Azure AD Identity Protection
    - Allows to accomplish three key tasks
        - automate the detection and remediation of identity-based risks
        - investigate risks using data in the portal
        - export risk detection data to third party utilities for further analysis


### Describe the capabilities of Microsoft Security Solutions (30-35%)

Describe basic security capabilities in Azure
- [ ] describe Azure Network Security groups
- [ ] describe Azure DDoS protection
- [ ] describe what Azure Firewall is
- [ ] describe what Azure Bastion is
- [ ] describe what Web Application Firewall is
- [ ] describe ways Azure encrypts data

Describe security management capabilities of Azure
- [x] describe the [Azure Security center](https://docs.microsoft.com/en-us/azure/security-center/security-center-introduction)
    - What is the compliance state
    - Unified infrastructure security management system
    - Cloud Security Posture Management (CSPM)
    - strengthen security posture of data centers
    - provides advanced threat protection across workloads in the cloud (azure or other) and on prem
- [x] describe Azure Secure score
- [x] describe the benefit and use cases of Azure Defender - previously the cloud workload protection platform (CWPP)
- [x] describe Cloud security posture management (CSPM)
- [x] describe security baselines for Azure
    - security baseline involves classification of the digital estate and data, documentation of risks, business tolerance and mitigation strategies associated with the security of data, assets and networks.
    - [Security center baseline](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/security-center-security-baseline)
    - [Azure tools for security baseline](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/govern/security-baseline/toolchain) 

Describe security capabilities of Azure Sentinel
- [x] define the concepts of SIEM, SOAR, XDR
    - XDR: Extended Detection and Response (Microsoft Defender)
        - SaaS-based, vendor-specific, security threat detection and incident response tool that natively integrates multiple security products into a cohesive security operations system that unifies all licensed components
        - Collects and correlates data across network endpoints. Analyses and presents to give visibility and context.
    - SIEM: Secure Information and Event Management (Real time analysis and security alerts)
    - SOAR: Security Orchestration, Automation and Response 
- [x] describe the role and value of Azure Sentinel to provide integrated threat protection
    - Cloud native SIEM and SOAR
    - collect data across users, devices, apps, and infrastructure, on-prem and cloud
    - uses Microsoft's threat intel to find new threats
    - use AI to operate at scale

Describe threat protection with Microsoft 365 Defender (formerly Microsoft Threat Protection)
- [x] describe Microsoft 365 Defender services
- [x] describe Microsoft Defender for Identity (formerly Azure ATP)
    - on-prem AD signals to detect attacks
    - sit side-by-side with Identity protection which is looking at the AAD
- [x] describe Microsoft Defender for Office 365 (formerly Office 365 ATP)
    - ability to protect users that are using office 365
- [x] describe Microsoft Defender for Endpoint (formerly Microsoft Defender ATP)
    - looks at whats the entry point for an attack
    - what happened from this user to that user
    - complete tracking for Windows, Linux and MacOS
- [x] describe Microsoft Cloud App Security (CASB)
    - what are the apps being spoken to from my corp
    - bring your own IT department
    - discovery
    - control

Describe security management capabilities of Microsoft 365
- [ ] describe the Microsoft 365 Security Center
- [ ] describe how to use Microsoft Secure Score
- [ ] describe security reports and dashboards
- [ ] describe incidents and incident management capabilities

Describe endpoint security with Microsoft Intune
- [x] describe what Intune is
    - policy engine goes with AAD (there is no group policy)
    - policy
    - health
    - devices, its about the client device
    - Mobile Device Management (MDM)
        - enrolling the device
        - complete management
    - Mobile App Policy
        - application policies
        - can't enforce things at the device level, only at the apps
        - personal devices
- [ ] describe endpoint security with Intune
- [ ] describe the endpoint security with the Microsoft Endpoint Manager admin center


### Describe the Capabilities of Microsoft Compliance Solutions (25-30%)

Describe the compliance management capabilities in Microsoft
- [ ] describe the compliance center
- [ ] describe compliance manager
- [ ] describe use and benefits of compliance score

Describe information protection and governance capabilities of Microsoft 365
- [ ] describe data classification capabilities
- [ ] describe the value of content and activity explorer
- [ ] describe sensitivity labels
- [ ] describe Retention Polices and Retention Labels
- [ ] describe Records Management
- [ ] describe Data Loss Prevention

Describe insider risk capabilities in Microsoft 365
- [ ] describe Insider risk management solution
- [ ] describe communication compliance
- [ ] describe information barriers
- [ ] describe privileged access management
- [ ] describe customer lockbox

Describe the eDiscovery capabilities of Microsoft 365
- [ ] describe the purpose of eDiscovery
- [ ] describe the capabilities of the content search tool
- [ ] describe the core eDiscovery workflow
- [ ] describe the advanced eDisovery workflow

Describe the audit capabilities in Microsoft 365
- [ ] describe the core audit capabilities of M365
- [ ] describe purpose and value of Advanced Auditing

Describe resource governance capabilities in Azure
- [ ] describe the use of Azure Resource locks
- [ ] describe what Azure Blueprints is 
- [ ] define Azure Policy and describe its use cases
- [ ] describe cloud adoption framework
 
