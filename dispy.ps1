# dispy.ps1 
#
# This script takes in an AD Group and a display name to update it to
# It outputs the existing display name, then the updated display name

#define parameters
param (
    [string]$adgroup,
    [string]$dispname
 )

if ($adgroup -like "help" -Or "-h")
{
    Write-Host "Script usage: .\dispy.ps1 <ADGROUP> <DISPLAYNAME>"
    Write-Host "Script takes in an AD Group and a Display Name, then updates the provided Group's display name to the one provided."
    Write-Host "Provide 'help' or '-h' to display this message."
    exit 
}

# Get the AD Group and output its current display name 
$dispthen = Get-ADGroup -Identity $adgroup -Properties * | select DisplayName
Write-Host "`nFetching current display name ..." 
Write-Host "$adgroup : $dispthen"

# Inform script-caller that the script is proceeding to update the display name
Write-Host "`nAttempting to set display name to provided argument ..." 
Write-Host "Provided Display Name: $dispname" 

# Get the AD Group and set it's display name 
Get-ADGroup -Identity "$adgroup" | Set-ADGroup -DisplayName "$dispname"

# Get the new display name for script-caller verification
$dispnow = Get-ADGroup -Identity $adgroup -Properties * | select DisplayName
Write-Host "`nFetching new display name ..." 
Write-Host "$adgroup : $dispnow"