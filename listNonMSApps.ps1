# Function to list all installed software that is not from Microsoft
function List-NonMicrosoftSoftware {
    # Get all installed applications
    $installedApps = Get-WmiObject -Class Win32_Product

    # Filter out Microsoft applications
    $nonMicrosoftApps = $installedApps | Where-Object { $_.Vendor -notlike "*Microsoft*" }

    # Display the non-Microsoft applications with version and install date
    $nonMicrosoftApps | Select-Object Name, Vendor, Version, InstallDate | Format-Table -AutoSize
}

# Run the function
List-NonMicrosoftSoftware