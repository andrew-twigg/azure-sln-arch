param(
    [string]$DomainName,
    [string]$DomainNetBIOSName
)

# Ref. https://docs.microsoft.com/en-us/azure/active-directory/hybrid/tutorial-password-hash-sync#create-a-windows-server-ad-environment

Write-Host "Script to create AD DS forest."
Write-Host "DomainName=$DomainName"
Write-Host "DomainNetBIOSName=$DomainNetBIOSName"

$DatabasePath = "c:\windows\NTDS"
$DomainMode = "WinThreshold"
$ForestMode = "WinThreshold"
$LogPath = "F:\windows\NTDS"
$SysVolPath = "F:\windows\SYSVOL"
$featureLogPath = "F:\poshlog\featurelog.txt" 
$Password = "Pass1w0rd" # DON'T DO THIS FOR REAL! THIS IS EPHEMERAL DEMO ENV.
$SecureString = ConvertTo-SecureString $Password -AsPlainText -Force
$addsTools="RSAT-AD-Tools"

#Install features
New-Item $featureLogPath -ItemType file -Force 
Add-WindowsFeature $addsTools 
Get-WindowsFeature | Where installed >>$featureLogPath

#Install AD DS, DNS and GPMC 
start-job -Name addFeature -ScriptBlock { 
    Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools 
    Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools 
    Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools
}
Wait-Job -Name addFeature 
Get-WindowsFeature | Where installed >>$featureLogPath

#Create New AD Forest
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath $DatabasePath `
    -DomainMode $DomainMode `
    -DomainName $DomainName `
    -SafeModeAdministratorPassword $SecureString `
    -DomainNetbiosName $DomainNetBIOSName `
    -ForestMode $ForestMode `
    -InstallDns:$true `
    -LogPath $LogPath `
    -NoRebootOnCompletion:$false `
    -SysvolPath $SysVolPath `
    -Force:$true

# Ref. https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/virtual-dc/adds-on-azure-vm#configure-the-first-domain-controller
#
# The Prerequisites Check will warn you that the physical network adapter does not
# have static IP address(es) assigned, you can safely ignore this as static IPs are
# assigned in the Azure virtual network.
