param(
    [string]$GivenName,
    [string]$Surname,
    [string]$DisplayName,
    [string]$Name,

    # TODO: SecureString parameter
    [string]$Password,

    [string]$Identity
)


# $Givenname = "Allie"
# $Surname = "McCray"
# $Displayname = "Allie McCray"
# $Name = "amccray"
# $Password = "Pass1w0rd"
# $Identity = "CN=ammccray,CN=Users,DC=contoso,DC=com"

# TODO: SecureString parameter.
$SecureString = ConvertTo-SecureString $Password -AsPlainText -Force

New-ADUser `
    -Name $Name `
    -GivenName $GivenName `
    -Surname $Surname `
    -DisplayName $DisplayName `
    -AccountPassword $SecureString

Set-ADUser `
    -Identity $Identity `
    -PasswordNeverExpires $true `
    -ChangePasswordAtLogon $false `
    -Enabled $true
