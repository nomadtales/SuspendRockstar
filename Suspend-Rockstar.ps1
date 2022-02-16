## Variables
$delay = 10
$nicdelay = 30
$choice = $null

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
While ($choice -ne 4)
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
        $FWPrompt = "Disable"
    }
    elseif ($FWRuleStatus -eq "False")
    {
        Write-Host "FireWall Rule: " -NoNewline
        Write-Host "Disabled" -BackgroundColor Red -ForegroundColor Black
        $FWPrompt = "Enable"
    }

    # Check NIC Status
    $NICStatus = (Get-NetAdapter -Physical).Status

    # Add helpful NIC  text
    if ($NICStatus -eq "Up")
    {
        Write-Host "NIC: " -NoNewline
        Write-Host "Up" -BackgroundColor Green -ForegroundColor Black
        $NICPrompt = "Disable"
    }
    elseif ($NICStatus -eq "Disabled")
    {
        Write-Host "NIC: " -NoNewline
        Write-Host "Down" -BackgroundColor Red -ForegroundColor Black
        $NICPrompt = "Enable"
    }

    # Add text for last Suspend Time
    if ($suspendtime) {"GTAO/RDO last suspended at: $suspendtime"}

    # prompt for rerun with a choice
    $title = 'What would you like to do?'
    $suspend = New-Object System.Management.Automation.Host.ChoiceDescription "&Suspend GTAO/RDO",'Suspend GTAO/RDO for $delay seconds'
    $fwswitch = New-Object System.Management.Automation.Host.ChoiceDescription "$FWPrompt &FireWall Rule",'Start/Stop the Firewall Rule'
    $nicswitch = New-Object System.Management.Automation.Host.ChoiceDescription "$NICPrompt &Physical NIC",'Enable/Disable Physical NIC'
    $nicreset = New-Object System.Management.Automation.Host.ChoiceDescription "Suspend Physical &NIC",'Suspend GTAO/RDO for $nicdelay seconds'
    $exit = New-Object System.Management.Automation.Host.ChoiceDescription "E&xit",'Disables the Firewall Rule and Exits'
    $options = [System.Management.Automation.Host.ChoiceDescription[]] ($suspend,$fwswitch,$nicswitch,$nicreset,$exit)

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
            Clear-Host
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
            Catch {
                Write-Warning "Could not Enable FireWall Rule"
                Start-Sleep -Seconds 5
            }
        } # End If

        # Disable the Firewall
        If ($FWRuleStatus -eq "True")
        {
            Try {Set-NetFirewallRule -DisplayName "Rockstar Solo Lobby" -Enabled False}
            Catch {
                Write-Warning "Could not Disable FireWall Rule"
                Start-Sleep -Seconds 5
            }
        } # End If
    } # End ElseIf

    # Enable or Disable the NIC choice
    elseif ($choice -eq 2) 
    {
        # Disable the NIC
        If ($NICStatus -eq "Up")
        {
            Try {Get-NetAdapter -Physical | Where-Object status -eq up | Disable-NetAdapter -Confirm:$false}
            Catch {
                Write-Warning "Could not Disable NIC"
                Start-Sleep -Seconds 5
            }
            
        } # End If

        # Enable the NIC
        If ($NICStatus -eq "Disabled")
        {
            Try {Get-NetAdapter -Physical | Where-Object status -eq Disabled | Enable-NetAdapter -Confirm:$false}
            Catch {
                Write-Warning "Could not Enable NIC"
                Start-Sleep -Seconds 5
            }
            
        } # End If
    } # End ElseIf

    # Rest the NIC choice
    elseif ($choice -eq 3) 
    {
        Try {Get-NetAdapter -Physical | Where-Object status -eq up | Disable-NetAdapter -Confirm:$false}
        Catch {Write-Warning "Could not Disable NIC"}
        Write-Warning "Pausing for NIC restart"
        Start-Sleep -Seconds $nicdelay
        Try {Get-NetAdapter -Physical | Where-Object status -eq Disabled | Enable-NetAdapter -Confirm:$false}
        Catch {
            Write-Warning "Could not Enable NIC"
            Start-Sleep -Seconds 5
        }

    } # End ElseIf

    # Quit if Exit selected
    elseif ($choice -eq 4) 
    {
        # Disable the Firewall
        If ($FWRuleStatus -eq "True")
        {
            Try {Set-NetFirewallRule -DisplayName "Rockstar Solo Lobby" -Enabled False}
            Catch {Write-Warning "Could not Disable FireWall Rule"}
        } # End If

        # Enable the NIC
        if ($NICStatus -eq "Disabled")
        {
            Try {Get-NetAdapter -Physical | Where-Object status -eq Disabled | Enable-NetAdapter -Confirm:$false}
            Catch {Write-Warning "Could not Enable NIC"}
        } # End If
        exit
    }
} # End While 
