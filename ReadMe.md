# Suspend-RDR2
Quick script to pause and restart Red Dead Redemption 2 process on PC. Specifically used when playing Red Dead Online as it will put you into a temporary solo lobby.

## Requirements
1. Download PSTools from https://docs.microsoft.com/en-us/sysinternals/downloads/pstools
2. Unzip into a folder of your choice.
3. Add the PSTools folder into the Windows Environmental Path (Instructions here https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/).

## Setup
1. Change PowerShell Execution Policy if not previously done, by starting PowerShell as an Administrator and using `Set-ExecutionPolicy Bypass`.
2. Create a desktop shortcut.
3. Add the following to the "Type the location of the item" box: `powershell.exe -command "Invoke-Command -ScriptBlock ([ScriptBlock]::Create((Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/nomadtales/DirtyScripting/master/PowerShell/Suspend-RDR2.ps1' -UseBasicParsing).Content))"`.
4. Call the Shortcut "RDR2 Suspend" and click Finish.