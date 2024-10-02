# Define the URL of the executable file
$exeUrl = "https://download.booster.gearupportal.com/9166/GearUP-2.13.0-win.exe?name=GearUP-2.13.0-win.exe"

# Define the temporary file path for the executable file
$tempExePath = "$env:TEMP\GearUP-2.13.0-win.exe"

# Download the executable file to the temporary location
Start-BitsTransfer -Source $exeUrl -Destination $tempExePath

# Define the extraction path
$extractPath = "$env:TEMP\GearUP Booster"

# Create the extraction directory if it doesn't exist
if (-Not (Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath
}

# Unzip the downloaded file to the extraction path using 7-Zip
& "C:\Program Files\7-Zip\7z.exe" x "$tempExePath" -o"$extractPath" -y

# Define the destination path
$destPath = "C:\Program Files (x86)\GearUP Booster"

# Create the destination directory if it doesn't exist
if (-Not (Test-Path -Path $destPath)) {
    New-Item -ItemType Directory -Path $destPath
}

# Copy the extracted folder to the destination path
Copy-Item -Path "$extractPath\*" -Destination $destPath -Recurse -Force

# Create a shortcut for the executable in the Startup folder
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\GearUP Booster.lnk")
$shortcut.TargetPath = "$destPath\launcher.exe"
$shortcut.Save()

# Create a shortcut for the executable in the Start Menu
$startMenuShortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\GearUP Booster.lnk")
$startMenuShortcut.TargetPath = "$destPath\launcher.exe"
$startMenuShortcut.Save()

# Create a desktop shortcut for the executable
$desktopShortcut = $WScriptShell.CreateShortcut("$env:USERPROFILE\Desktop\GearUP Booster.lnk")
$desktopShortcut.TargetPath = "$destPath\launcher.exe"
$desktopShortcut.Save()

# Create a desktop shortcut for the uninstall script
$desktopUninstallShortcut = $WScriptShell.CreateShortcut("$env:USERPROFILE\Desktop\GearUP Booster Uninstall.lnk")
$desktopUninstallShortcut.TargetPath = "powershell.exe"
$desktopUninstallShortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$uninstallScriptPath`""
$desktopUninstallShortcut.Save()

# Create an uninstall script
$uninstallScript = @"
Remove-Item -Path '$destPath' -Recurse -Force
"@
$uninstallScriptPath = "$destPath\uninstall.ps1"
Set-Content -Path $uninstallScriptPath -Value $uninstallScript

# Create a shortcut for the uninstall script
$uninstallShortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\GearUP Booster_uninstall.lnk")
$uninstallShortcut.TargetPath = "powershell.exe"
$uninstallShortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$uninstallScriptPath`""
$uninstallShortcut.Save()

# Register the application in the Windows "Apps & features" list
$uninstallRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GearUP Booster"
if (-Not (Test-Path -Path $uninstallRegPath)) {
    New-Item -Path $uninstallRegPath -Force
}
Set-ItemProperty -Path $uninstallRegPath -Name "DisplayName" -Value "GearUP Booster"
Set-ItemProperty -Path $uninstallRegPath -Name "UninstallString" -Value "$destPath\uninstall.exe"
Set-ItemProperty -Path $uninstallRegPath -Name "DisplayIcon" -Value "$destPath\launcher.exe"
Set-ItemProperty -Path $uninstallRegPath -Name "Publisher" -Value "GearUP Booster"
Set-ItemProperty -Path $uninstallRegPath -Name "DisplayVersion" -Value "2.13.0"
Set-ItemProperty -Path $uninstallRegPath -Name "InstallLocation" -Value $destPath
Set-ItemProperty -Path $uninstallRegPath -Name "NoModify" -Value 1 -Type DWord
Set-ItemProperty -Path $uninstallRegPath -Name "NoRepair" -Value 1 -Type DWord

# Remove temporary files
Remove-Item -Path $tempExePath -Force
Remove-Item -Path $extractPath -Recurse -Force
