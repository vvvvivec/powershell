# This script pulls a list of all current ad groups a user is a member of 
# $control - determines action of script
# $userid - user n# to search
# $vector - stu- branch to look for matches

# define parameters
param (
    $control,
    $userid,
    $vector
)

# construct help message 
$helpmsg = "`nSyntax: .\control-checkgroups.ps1 <control> <userid> <vector>"
$helpmsg += "`n`ncontrol - valid options: help, check, verify"
$helpmsg += "`nhelp - display help message"
$helpmsg += "`ncheck - check what groups user is a member of"
$helpmsg += "`nverify - verify user's full name"
$helpmsg += "`n`nuserid - n# of user to check"
$helpmsg += "`nvector - filter to apply, e.g. 'stu-'"

# if $control == check , check groups $userid belongs to
if ($control -like 'check')
{
    # if no vector is supplied , get all groups
    if (!$vector)
    {
    Get-ADPrincipalGroupMembership -Identity $userid | Select -Property name 
    }

    # if vector is supplied , get groups with grep on vector 
    else
    {
    Get-ADPrincipalGroupMembership -Identity $userid | Select -Property name | sls $vector
    }
}

# if $control == verify , get $userid's first and last name
if ($control -like 'verify')
{
    Get-ADUser -Identity $userid | Select -Property 'givenname', surname
}

# if $control == help , display help message 
if ($control -like 'help')
{
    Write-Host $helpmsg
}

# if no valid control supplied , display error along with syntax for help message
elseif (!$control)
{
    Write-Host "Error, invalid control provided`nProper syntax: .\control-checkgroups.ps1 <control> <userid> <vector>"
    Write-Host "For information, use: .\control-checkgroups.ps1 help"
}
