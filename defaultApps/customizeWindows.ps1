# Remove the Windows Store icon from the taskbar for all users
Write-Host "Removing Windows Store icon from the taskbar for all users..." -ForegroundColor Green

# Define the path to the LayoutModification.json file for the default user
$layoutFilePath = "$Env:ProgramData\Microsoft\Windows\Shell\LayoutModification.json"

# Ensure the directory exists
$layoutDirectory = [System.IO.Path]::GetDirectoryName($layoutFilePath)
if (-Not (Test-Path -Path $layoutDirectory)) {
    Write-Host "Creating the directory: $layoutDirectory" -ForegroundColor Yellow
    New-Item -Path $layoutDirectory -ItemType Directory -Force | Out-Null
}

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

# Create or update the LayoutModification.json file
try {
    Write-Host "Creating or updating LayoutModification.json file..." -ForegroundColor Yellow
    $customLayout | Set-Content -Path $layoutFilePath -Encoding UTF8 -Force
    Write-Host "LayoutModification.json file has been successfully updated." -ForegroundColor Green
} catch {
    Write-Host "Error writing LayoutModification.json file: $_" -ForegroundColor Red
}

# Apply the changes to all users
Write-Host "Applying taskbar and Start Menu layout changes for all users..." -ForegroundColor Green
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
try {
    if (-Not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "UseDefaultTile" -Value 1
    Write-Host "Taskbar layout changes have been applied." -ForegroundColor Green
} catch {
    Write-Host "Error applying taskbar layout changes: $_" -ForegroundColor Red
}

# Remove all recommended shortcuts from the Start Menu
Write-Host "Removing all recommended shortcuts from the Start Menu for all users..." -ForegroundColor Green

# Define registry paths for recommended Start Menu items
try {
    Set-ItemProperty -Path $regPath -Name "HideRecommendedSection" -Value 1
    Write-Host "All recommended shortcuts have been removed from the Start Menu for all users." -ForegroundColor Green
} catch {
    Write-Host "Error modifying Start Menu settings: $_" -ForegroundColor Red
}

# Confirmation
Write-Host "Pinned apps have been updated to only include Edge, File Explorer, Snipping Tool, and Calculator." -ForegroundColor Green
