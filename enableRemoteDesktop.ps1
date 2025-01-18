# Enable Remote Desktop
Write-Host "Enabling Remote Desktop..." -ForegroundColor Green
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0

# Configure Firewall to allow Remote Desktop
Write-Host "Configuring Windows Firewall to allow Remote Desktop..." -ForegroundColor Green
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Check if Remote Desktop is enabled
$rdpEnabled = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\').fDenyTSConnections -eq 0
if ($rdpEnabled) {
    Write-Host "Remote Desktop has been successfully enabled." -ForegroundColor Green
} else {
    Write-Host "Failed to enable Remote Desktop. Please check your settings." -ForegroundColor Red
}

# Optional: Allow Network Level Authentication (NLA)
Write-Host "Configuring Network Level Authentication (NLA)..." -ForegroundColor Green
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 1

Write-Host "Windows Remote Desktop configuration is complete." -ForegroundColor Green
