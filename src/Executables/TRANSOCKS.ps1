# Define the URL of the executable file
$exeUrl = "https://dl.chuansuo.io/download/transocks/package/pc/3.4.3/Transocks_Win_v3.4.3_official_x64.exe"

# Define the temporary file path for the executable file
$tempExePath = "$env:TEMP\Transocks_Win_v3.4.3_official_x64.exe"

# Download the executable file to the temporary location
Start-BitsTransfer -Source $exeUrl -Destination $tempExePath

# Define the extraction path
$extractPath = "$env:TEMP\Transocks"

# Create the extraction directory if it doesn't exist
if (-Not (Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath
}

# Unzip the downloaded file to the extraction path using 7-Zip
& "C:\Program Files\7-Zip\7z.exe" x "$tempExePath" -o"$extractPath" -y

# Define the destination path
$destPath = "C:\Program Files\Transocks"

# Copy the extracted folder to the destination path
Copy-Item -Path "$extractPath\*" -Destination $destPath -Recurse -Force

# Create a shortcut for the executable in the Startup folder
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Transocks.lnk")
$shortcut.TargetPath = "$destPath\transocks.exe"
$shortcut.Save()

# Create a shortcut for the executable in the Start Menu
$startMenuShortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Transocks.lnk")
$startMenuShortcut.TargetPath = "$destPath\transocks.exe"
$startMenuShortcut.Save()

# Create an uninstall script
$uninstallScript = @"
Remove-Item -Path '$destPath' -Recurse -Force
"@
$uninstallScriptPath = "$destPath\uninstall.ps1"
Set-Content -Path $uninstallScriptPath -Value $uninstallScript

# Create a shortcut for the uninstall script
$uninstallShortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Transocks_uninstall.lnk")
$uninstallShortcut.TargetPath = "powershell.exe"
$uninstallShortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$uninstallScriptPath`""
$uninstallShortcut.Save()

# Register the application in the Windows "Apps & features" list
$uninstallRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Transocks"
if (-Not (Test-Path -Path $uninstallRegPath)) {
    New-Item -Path $uninstallRegPath -Force
}
Set-ItemProperty -Path $uninstallRegPath -Name "DisplayName" -Value "Transocks"
Set-ItemProperty -Path $uninstallRegPath -Name "UninstallString" -Value "$destPath\Uninstall.exe"
Set-ItemProperty -Path $uninstallRegPath -Name "DisplayIcon" -Value "$destPath\transocks.exe"
Set-ItemProperty -Path $uninstallRegPath -Name "Publisher" -Value "Transocks"
Set-ItemProperty -Path $uninstallRegPath -Name "DisplayVersion" -Value "3.4.3"
Set-ItemProperty -Path $uninstallRegPath -Name "InstallLocation" -Value $destPath
Set-ItemProperty -Path $uninstallRegPath -Name "NoModify" -Value 1 -Type DWord
Set-ItemProperty -Path $uninstallRegPath -Name "NoRepair" -Value 1 -Type DWord

# Remove temporary files
Remove-Item -Path $tempExePath -Force
Remove-Item -Path $extractPath -Recurse -Force
