## Variables
$delay = 10

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