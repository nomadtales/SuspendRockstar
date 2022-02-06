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
$FWRule = Get-NetFirewallRule -DisplayName "Rockstar Solo Lobby" -ErrorAction SilentlyContinue

# If the FireWall Rule does not exist, create it
If (!$FWRule)
{
    "Creating new Firewall Rule to block udp on ports 6672, 61455-61458"
    New-NetFirewallRule -DisplayName "Rockstar Solo Lobby" -Direction Outbound -Action Block -Protocol UDP -RemotePort 6672,61455-61458 -Confirm
} # End If

# Disable the Firewall
Set-NetFirewallRule -DisplayName "Rockstar Solo Lobby" -Enabled False -ErrorAction SilentlyContinue

# Create a loop to allow for rerunning
While ($choice -ne 2)
{
    # Clear the PS Window
    Clear-Host

    # Check FireWall Rule Status
    $FWRuleStatus = (Get-NetFirewallRule -DisplayName "Rockstar Solo Lobby").Enabled

    # Add helpful FireWall text
    if ($FWRuleStatus -eq "True")
    {
        Write-Host "FireWall Rule: " -NoNewline
        Write-Host "Enabled" -BackgroundColor Green -ForegroundColor Black
    }
    elseif ($FWRuleStatus -eq "False")
    {
        Write-Host "FireWall Rule: " -NoNewline
        Write-Host "Disabled" -BackgroundColor Red -ForegroundColor Black
    }

    # Add text for last Suspend Time
    if ($suspendtime) {"GTAO/RDO last suspended at: $suspendtime"}

    # prompt for rerun with a choice
    $title = 'What would you like to do?'
    $suspend = New-Object System.Management.Automation.Host.ChoiceDescription '&Suspend GTAO/RDO',"Suspend GTAO/RDO for $delay seconds"
    $fwswitch = New-Object System.Management.Automation.Host.ChoiceDescription 'Enable/Disable &FireWall Rule','Start/Stop the Firewall Rule'
    $exit = New-Object System.Management.Automation.Host.ChoiceDescription 'E&xit','Disables the Firewall Rule and Exits'
    $options = [System.Management.Automation.Host.ChoiceDescription[]] ($suspend,$fwswitch,$exit)

    $choice = $host.ui.PromptForChoice($title,$null,$options,0)

    # Suspend RDO choice
    if ($choice -eq 0) 
    {
        # Grab the process id of the GTAV/RDR2 process
        $ps = (Get-Process | Where-Object Name -match "^GTA5|^RDR2" -ErrorAction SilentlyContinue).Id

        # Suspend for delay time if process is running
        if ($ps)
        {
            & 'pssuspend64.exe' -nobanner "$ps"
            Start-Sleep -Seconds $delay
            & 'pssuspend64.exe' -r -nobanner "$ps"
            $suspendtime = Get-Date
        } # End If

        # else ignore
        else 
        {
            "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - GTAV/RDR2 Not Running"
            Start-Sleep -Seconds 5
        } # End else
    } # End ElseIf

    # Start or Stop FireWall Rule choice
    elseif ($choice -eq 1) 
    {
        # Enable the Firewall
        If ($FWRuleStatus -eq "False")
        {
            Try {Set-NetFirewallRule -DisplayName "Rockstar Solo Lobby" -Enabled True}
            Catch {Write-Warning "Could not Enable FireWall Rule"}
        } # End If

        # Disable the Firewall
        If ($FWRuleStatus -eq "True")
        {
            Try {Set-NetFirewallRule -DisplayName "Rockstar Solo Lobby" -Enabled False}
            Catch {Write-Warning "Could not Disable FireWall Rule"}
        } # End If
    } # End ElseIf

    # Quit if Exit selected
    if ($choice -eq 2) 
    {
        # Disable the Firewall
        If ($FWRuleStatus -eq "True")
        {
            Try {Set-NetFirewallRule -DisplayName "Rockstar Solo Lobby" -Enabled False}
            Catch {Write-Warning "Could not Disable FireWall Rule"}
        } # End If
        exit
    }
} # End While 
