# Remove the Windows Store icon from the taskbar for all users
Write-Host "Removing Windows Store icon from the taskbar for all users..." -ForegroundColor Green

# Define the path to the LayoutModification.json file for the default user
$layoutFilePath = "$Env:ProgramData\Microsoft\Windows\Shell\LayoutModification.json"

# Define the layout to retain specific pinned apps
$customLayout = @'
{
    "pinnedList": [
        { "desktopAppId": "Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe!MicrosoftEdge" },
        { "desktopAppId": "Microsoft.Windows.Explorer" },
        { "desktopAppId": "Microsoft.ScreenSketch_8wekyb3d8bbwe!App" },
        { "desktopAppId": "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App" }
    ]
}
'@

# Check if the file exists; if not, create it
if (-Not (Test-Path -Path $layoutFilePath)) {
    Write-Host "Creating a new LayoutModification.json file with custom pinned apps..." -ForegroundColor Yellow
    $customLayout | Set-Content -Path $layoutFilePath -Encoding UTF8
} else {
    Write-Host "Updating LayoutModification.json file with custom pinned apps..." -ForegroundColor Yellow
    $customLayout | Set-Content -Path $layoutFilePath -Encoding UTF8
}

# Apply the changes to all users
Write-Host "Applying taskbar and Start Menu layout changes for all users..." -ForegroundColor Green
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
if (-Not (Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force
}
Set-ItemProperty -Path $regPath -Name "UseDefaultTile" -Value 1

# Remove all recommended shortcuts from the Start Menu for all users
Write-Host "Removing all recommended shortcuts from the Start Menu for all users..." -ForegroundColor Green

# Define registry paths for recommended Start Menu items
$startMenuRegPath = "HKLM:\Software\Policies\Microsoft\Windows\Explorer"

# Ensure the path exists
if (-Not (Test-Path -Path $startMenuRegPath)) {
    New-Item -Path $startMenuRegPath -Force
}

# Disable Recommended section in the Start Menu
Set-ItemProperty -Path $startMenuRegPath -Name "HideRecommendedSection" -Value 1

Write-Host "All recommended shortcuts have been removed from the Start Menu for all users." -ForegroundColor Green

# Confirmation
Write-Host "Pinned apps have been updated to only include Edge, File Explorer, Snipping Tool, and Calculator." -ForegroundColor Green
