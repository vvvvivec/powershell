#    .\raygun.ps1 
#
#    'less qq more pewpew'
#
#    Author: Brian D.
#    Date: 110117
#    Version 0001
#
#    Description: 
#    This script executes SEP scans on remote machines and pulls SEP logs for ITSecurity documentation purposes.
#     
#    Use:   .\raygun.ps1 <$command> <$compname>
#
#    $command : scan , fetch , help
#         scan  - Start an SEP scan on the designated remote machine
#         fetch - Fetch scan result logs from most recent SEP log entries
#         help  - Display help message
#    $compname : name of computer to scan 

# Define Parameters
param (
    $command,
    $computer
)

# Set path for psexec.exe 
$targetPath = "\\Kandor\DSL\SA\psexec.exe"

# Display provided arguments
# If computer is provided , output it , otherwise don't
# Same logic applies to command
if ($computer)
{
    Write-Host "`nTarget: $computer"
}
if ($command)
{
    Write-Host "Executing: $command"
}

# Build error message
$errorMessage =  "`nUnable to execute remote command.`nPerhaps the host is offline or the hostname is incorrect?"

# If $command == scan , execute SEP scan on $computer
if (($command -like 'scan') -and ($computer))
{
    # Try to execute the remote command
    Try
    {
        # Assemble the psexec command string
        # It must be done this way in order for single and double quotes (',") to be interpreted correctly
        # Otherwise the command will not successfully execute
        $remoteTarget = "\\$computer -s -d " 
        $remoteCmd = '"c:\Program Files (x86)\Symantec\Symantec Endpoint Protection\doscan.exe" /cmdlinescan /ScanAllDrives'
        $remoteComplete = $remoteTarget+$remoteCmd

        # Echo the provided command
        Write-Host "`nExecuting the following command on provided target: $remoteComplete"

        # Start the psexec process and wait for the scan to start before exiting psexec 
        Start-Process -FilePath "$targetPath" -ArgumentList "$remoteComplete" -PassThru -Wait 

        # Get the most recent log, which should be the scan start log, for documentation purposes 
        Get-EventLog -Newest 1 -LogName "Symantec Endpoint Protection Client" -ComputerName "$computer" | Format-List -Property * 
    }
    # Catch Exceptions and display error message
    Catch
    {
       Write-Host $errorMessage
    }
}

# If $command == fetch , get the most recent complete scan logs from the newest 10 logs for documentation purposes 
if (($command -like 'fetch') -and ($computer))
{
    # Try to fetch the logs
    Try 
    {
        # Pull the newest 10 logs and output any where the event type is a scan result, ID is 2 
        Get-EventLog -Newest 10 -LogName "Symantec Endpoint Protection Client" -Source "Symantec Endpoint Protection Client" -ComputerName "$computer" | where {$_.EventID -eq 2} | Format-List -Property *
    }
    # Catch Exceptions and display error message 
    Catch
    {
        Write-Host $errorMessage
    }
}

# If $command == help , display help message
if (($command -like 'help') -or ($command -like ''))
{
    Write-Host "`nUse: .\raygun.ps1 <command> <compname>"
    Write-Host "compname - Computer name of desired target mahcine"  
    Write-Host "Valid commands: scan , fetch, help"
    Write-Host "Scan - Start full SEP scan on targeted computer"
    Write-Host "Fetch - Get 10 most recent SEP logs and filter for scan result events only"
    Write-Host "Help - Display this message"
    Write-Host "Example input: .\raygun.ps1 scan myPC"
}