## Variables
$delay = 10

# Check if Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
If (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning "Please Run as Administrator. Press any key to exit."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
} # End If

# Check if Firewall Rule exists
$FWRule = Get-NetFirewallRule -DisplayName "RDO Solo Lobby" -ErrorAction SilentlyContinue

# If the FireWall Rule does not exist, create it
If (!$FWRule)
{
    "Creating new Firewall Rule to block udp on ports 6672, 61455-61458"
    New-NetFirewallRule -DisplayName "RDO Solo Lobby" -Direction Outbound -Action Block -Protocol UDP -RemotePort 6672,61455-61458 -Confirm
} # End If

# Disable the Firewall
Set-NetFirewallRule -DisplayName "RDO Solo Lobby" -Enabled False -ErrorAction SilentlyContinue

# Create a loop to allow for rerunning
While ($choice -ne 2)
{

    # Clear the PS Window
    Clear-Host

    # Check FireWall Rule Status
    $FWRuleStatus = (Get-NetFirewallRule -DisplayName "RDO Solo Lobby").Enabled

    "FireWall Rule Status: $FWRuleStatus"

    # prompt for rerun with a choice
    $title = 'What would you like to do?'
    $rerun = New-Object System.Management.Automation.Host.ChoiceDescription '&Suspend RDO',"Suspend RDO for $delay seconds"
    $fwswitch = New-Object System.Management.Automation.Host.ChoiceDescription '&FireWall Rule','Start/Stop the Firewall Rule'
    $exit = New-Object System.Management.Automation.Host.ChoiceDescription '&Exit','Aborts the script'
    $options = [System.Management.Automation.Host.ChoiceDescription[]] ($rerun,$fwswitch,$exit)
    
    $choice = $host.ui.PromptForChoice($title,$null,$options,0)

    # Quit if Exit selected
    if ($choice -eq 2) {exit}

    # Suspend RDO choice
    elseif ($choice -eq 0) 
    {
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
        } # End If

        # else ignore
        else {"$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - RDR2 Not Running"}
    } # End ElseIf

    # Start or Stop FireWall Rule choice
    elseif ($choice -eq 1) 
    {
        # Disable the Firewall
        If ($FWRuleStatus -eq "Disabled")
        {
            Try {Set-NetFirewallRule -DisplayName "RDO Solo Lobby" -Enabled True}
            Catch {Write-Warning "Could not Enable FireWall Rule"}
        } # End If

        # Disable the Firewall
        If ($FWRuleStatus -eq "Enabled")
        {
            Try {Set-NetFirewallRule -DisplayName "RDO Solo Lobby" -Enabled False}
            Catch {Write-Warning "Could not Disable FireWall Rule"}
        } # End If
    } # End ElseIf
} # End While 