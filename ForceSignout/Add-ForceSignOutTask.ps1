<#
    Script Name: Add-ForceSignOutTask.ps1
    Author: Chris Roessler
    Date: 02/12/2025
    Version: 1.0
    Description: 
        - This script creates a scheduled task to run ForceSignOut.ps1 at 1 AM daily.
        - It ensures the task runs with highest privileges.
        - The task will execute even if no user is logged in.
#>

# Define task parameters
$TaskName = "ForceSignOut"
$ScriptPath = "C:\Scripts\ForceSignOut.ps1"
$TaskLogPath = "C:\Temp\ForceSignOut.log"

# Ensure C:\Scripts exists, if not, create it
if (!(Test-Path "C:\Scripts")) {
    New-Item -Path "C:\Scripts" -ItemType Directory -Force
}

# Ensure C:\Temp exists for logging
if (!(Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory -Force
}

# Check if the ForceSignOut script exists
if (!(Test-Path $ScriptPath)) {
    Write-Output "ERROR: ForceSignOut.ps1 does not exist at $ScriptPath."
    Write-Output "Please ensure the script is in the correct directory."
    exit 1
}

# Define the action to run PowerShell with the ForceSignOut script
$Action = New-ScheduledTaskAction -Execute "powershell.exe" 
