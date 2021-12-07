## Variables
$delay = 10

# Check if Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
If (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning "Please Run as Administrator"
    

}


# Check if Firewall Rule exists
$FWRule = Get-NetFirewallRule -DisplayName "RDO Solo Lobby"

# If the FireWall Rule does not exist create it
If (!$FWRule)
{
    "Creating new Firewall Rule to block udp on ports 6672, 61455, 61457, 61456, 61458"
    New-NetFirewallRule -DisplayName "RDO Solo Lobby" -Direction Outbound -Action Block -Protocol UDP -RemotePort 6672,61455,61457,61456,61458 -Confirm
}

# Create a loop to allow for rerunning
While ($choice -ne 1)
{
    # Clear the PS Window
    Clear-Host

    # Grab the process id of the RDR2 process
    $ps = (Get-Process -Name RDR2 -ErrorAction SilentlyContinue).Id

    # Suspend for delay time if process is running
    if ($ps)
    {
        & 'pssuspend64.exe' -nobanner "$ps"
        "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - RDR2 Paused"
        Start-Sleep -Seconds $delay
        & 'pssuspend64.exe' -r -nobanner "$ps"
        "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - RDR2 Resumed"
    }

    # else ignore
    else {"$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - RDR2 Not Running"}

    # prompt for rerun with a choice
    $title = 'Would you like to rerun?'
    $rerun = New-Object System.Management.Automation.Host.ChoiceDescription '&Rerun','Rerun the script'
    $exit = New-Object System.Management.Automation.Host.ChoiceDescription '&Exit','Aborts the script'
    $options = [System.Management.Automation.Host.ChoiceDescription[]] ($rerun,$exit)
 
    $choice = $host.ui.PromptForChoice($title,$null,$options,0)
    
} # End While 