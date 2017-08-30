# control-sg 
# This script is used to add/remove members to the groups appropriate for a designated SG position 
# Author: Brian D. 
# Date: 08/18/17

# PARAMETERS: 

# $control: add , remove , check , purge , help
# add - adds specified user to vector group
# remove - removes specified user from vector group
# check - see what SG groups user belongs to
# purge - remove user from all SG groups
# help - display help message

# $userid: user account to manipulate 

# $vector: group to add/remove user to/from, utilizes last sections of STU-SG-SGAXXXXX, e.g. 'sgaag' 

# $flag: flag for DL AD group modification rather than standard STU-SG-* format 
param
(
    [string]$control,
    [string]$userid,
    [string]$vector,
    [string]$flag
)

# get list of members for $destination AD group to check against
function checkMembership()
{
    Get-ADGroupMember -Identity $destination -Recursive | Select -ExpandProperty Name
}

# help string for 'help' control
$helpString = "Syntax - .\control-sg.ps1 <control> <userid> <vector> <flag>`nControl - add, remove, purge, check, help" 
$helpString += "`nUserid - n# of user to add/remove`nVector - relative group to add/remove from , use SGA*"

# destination = AD group matched based on supplied $vector
# groups - gets a list of all STU-SG-* groups 
if ($flag -like 'dl')
{
    $destination = (Get-ADGroup -Filter "name -like 'STU-SGA-$vector*'").DistinguishedName
    $groups = (Get-ADGroup -Filter "name -like 'STU-SGA-*'").DistinguishedName    
}
else
{
    $destination = (Get-ADGroup -Filter "name -like 'STU-SG-$vector'").DistinguishedName
    $groups = (Get-ADGroup -Filter "name -like 'STU-SG-*'").DistinguishedName
}

# logic for 'add' control
# add user, check to make sure they were successfully added and write message to confirm
if ($control -like 'add')
{
    Add-ADGroupMember -Identity "$destination" -Members $userid
    $members = checkMembership
    if ($members -contains $userid)
    {
        Write-Host "User $userid successfully added to $vector`n$destination"
    }
}

# logic for 'remove' control
# check if $userid is member of designated group, if so remove and write message to confirm
# if not a member, write message stating user not found
if ($control -like 'remove')
{
    $members = checkMembership
    if ($members -contains $userid)
    {
        Write-Host "Removing User $userid from $vector`n$destination"
        Remove-ADGroupMember -Identity "$destination" -Members $userid -Confirm
    }    
    else
    {
        Write-Host "User $userid not found in $vector"
    }
}

# logic for 'check' control
# check against master list of SG AD groups, $groups 
# check each group to see if $Userid is a member
# write out message for each valid membership
if ($control -like 'check')
{
    foreach ($group in $groups)
    {
        $destination = $group 
        $members = checkMembership
        if ($members -contains $userid)
        {
            Write-Host "User $userid found in $group.DistinguishedName"
        }
    }
}

# logic for 'purge' control
# check which SG groups $userid belongs to and remove $userid from each
if ($control -like 'purge')
{
    foreach ($group in $groups)
    {
        $destination = $group
        $members = checkMembership
        if ($members -contains $userid)
        {
            Write-Host "Removing User $userid from $group"
            Remove-ADGroupMember -Identity "$group" -Members $userid -Confirm
        }
    }
}

# logic for 'help' control
# write out help string
if (($control -like 'help') -or ($control -like ''))
{
    Write-Host $helpString    
}