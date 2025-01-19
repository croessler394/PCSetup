# Function to check if the script is run as administrator
function Check-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Please run this script as an Administrator." -ForegroundColor Red
        exit
    }
}

# Function to remove unnecessary pre-installed apps
function Remove-UnnecessaryApps {
    $listPath = "remove_list.txt"
    
    if (Test-Path $listPath) {
        $apps = Get-Content -Path $listPath
    } else {
        Write-Host "The file $listPath does not exist. Please create it with the list of apps to remove."
        return
    }

    foreach ($app in $apps) {
        Get-AppxPackage -Name $app | Remove-AppxPackage
    }

    # Disable Cortana
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0

    # Disable Telemetry
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

    # Disable Windows Tips
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableSoftLanding" -Type DWord -Value 1

    # Disable Background Apps
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -Type DWord -Value 2

    # Disable Windows Defender (not recommended, consider using a good third-party antivirus)
    Set-MpPreference -DisableRealtimeMonitoring $true
}

# Function to list all installed software with version
function List-InstalledSoftware {
    Get-AppxPackage | Select-Object Name, PackageFullName, Version
}

# Function to display help
function Display-Help {
    Write-Host "Available options:"
    Write-Host "'debloat' - Run the debloat process to remove unnecessary pre-installed apps."
    Write-Host "'list' - List all installed software with their names, package names, and versions."
    Write-Host "'help' - Display this help message."
    Write-Host ""
    Write-Host "Apps that will be removed during the debloat process are listed in the file 'remove_list.txt'."
}

# Main script
Check-Administrator

$choice = Read-Host "Enter 'debloat' to run the debloat process, 'list' to list all installed software, or 'help' for options"

if ($choice -eq 'debloat') {
    Remove-UnnecessaryApps
    Write-Host "Debloat process completed."
} elseif ($choice -eq 'list') {
    List-InstalledSoftware | Format-Table -AutoSize
} elseif ($choice -eq 'help') {
    Display-Help
} else {
    Write-Host "Invalid option. Please enter 'debloat', 'list', or 'help'."
}