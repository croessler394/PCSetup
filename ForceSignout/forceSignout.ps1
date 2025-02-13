<#
    Script Name: ForceSignOut.ps1
    Author: Chris Roessler
    Date: 02/12/2025
    Version: 1.4
    Description: 
        - This script forces all active users to sign out between 1:00 AM and 1:05 AM.
        - It ensures the system clock is accurate by checking against an NTP server.
        - It logs the logouts to C:\Temp\ForceSignOut.log.
        - If C:\Temp does not exist, it creates it.
        - If the log file already exists, it appends data.
#>

# Define log file path
$LogFilePath = "C:\Temp\ForceSignOut.log"

# Ensure C:\Temp exists, if not, create it
if (!(Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory -Force
}

# Function to write log entries
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    Add-Content -Path $LogFilePath -Value $LogEntry
}

# Function to get accurate time from an NTP server
function Get-InternetTime {
    try {
        $NtpServer = "time.windows.com"
        $NtpQuery = w32tm /stripchart /computer:$NtpServer /dataonly /samples:1 2>&1
        $TimeLine = ($NtpQuery -match "\d{2}:\d{2}:\d{2}" | Select-Object -Last 1)
        if ($TimeLine) {
            return [datetime]::ParseExact($TimeLine, "HH:mm:ss", $null)
        }
    } catch {
        Write-Log "Error retrieving internet time."
    }
    return $null
}

# Get local and internet time
$LocalTime = Get-Date
$InternetTime = Get-InternetTime

# Allow execution between 1:00 AM and 1:05 AM
$AllowableHours = @(1)
$AllowableMinutes = @(0,1,2,3,4,5)

# Validate if system time is correct
if ($InternetTime -and [math]::Abs(($LocalTime - $InternetTime).TotalMinutes) -gt 5) {
    Write-Log "Warning: System clock is more than 5 minutes different from internet time."
}

# Run the script only within the allowable time range
if ($AllowableHours -contains $LocalTime.Hour -and $AllowableMinutes -contains $LocalTime.Minute) {
    Write-Output "It is now $($LocalTime.ToString('HH:mm')). Initiating forced sign-out..."
    Write-Log "Script started at $($LocalTime.ToString('HH:mm')). Checking for users to log out."

    # Function to log off all users
    function Force-LogoffUsers {
        Write-Output "Retrieving active user sessions..."

        # Get all active user sessions (excluding system accounts)
        $Sessions = quser | ForEach-Object {
            $parts = ($_ -split "\s{2,}")  # Split by multiple spaces
            if ($parts.Count -ge 3 -and $parts[1] -match '^\d+$') {
                [PSCustomObject]@{
                    UserName   = $parts[0]
                    SessionID  = $parts[1]
                    State      = $parts[2]
                }
            }
        }

        # Check if there are active sessions
        if ($Sessions) {
            foreach ($session in $Sessions) {
                Write-Output "Logging off user: $($session.UserName) (Session ID: $($session.SessionID))"
                logoff $session.SessionID 2>$null
                if ($?) {
                    Write-Output "Successfully logged off $($session.UserName)"
                    Write-Log "User $($session.UserName) (Session ID: $($session.SessionID)) logged out successfully."
                } else {
                    Write-Output "Failed to log off $($session.UserName)"
                    Write-Log "Failed to log out user $($session.UserName) (Session ID: $($session.SessionID))."
                }
            }
            Write-Output "All active users have been logged off."
        } else {
            Write-Output "No active user sessions found."
            Write-Log "No active user sessions found. No action taken."
        }
    }

    # Call the function to log off all users
    Force-LogoffUsers

    Write-Output "User logoff process completed."
    Write-Log "User logoff process completed."
} else {
    Write-Output "It is outside the execution window (1:00-1:05 AM). Script will not run."
}
