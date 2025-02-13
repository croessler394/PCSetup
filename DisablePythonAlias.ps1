# Define the alias paths
$pythonAlias = "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\python.exe"
$python3Alias = "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\python3.exe"

# Disable Python execution aliases (if they exist)
if (Test-Path $pythonAlias) {
    Remove-Item -Path $pythonAlias -Force
    Write-Output "Disabled execution alias for python.exe"
} else {
    Write-Output "python.exe alias not found."
}

if (Test-Path $python3Alias) {
    Remove-Item -Path $python3Alias -Force
    Write-Output "Disabled execution alias for python3.exe"
} else {
    Write-Output "python3.exe alias not found."
}

# Now disable the App Execution Aliases for Python from Windows Settings
$aliases = @("Python", "Python3")

foreach ($alias in $aliases) {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AppKey\{$alias}"
    if (Test-Path $path) {
        Remove-Item -Path $path -Force
        Write-Output "Removed execution alias for $alias"
    }
}

Write-Output "Python execution aliases have been removed or disabled."
