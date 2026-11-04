# This script has to be run in an elevated (Run as Administrator) terminal!

# taken from MS Learn, check if current user is Local Admin
$isLocalAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isLocalAdmin -ne $true) {
    Write-Host "Please run script as Administrator!"
    Exit
} else {
    Write-Host "You are running as Admin!"
}

# Check PS version at least 5.0.0
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "Please run in PowerShell version 5 or higher!"
    Exit
} else {
    Write-Host "Acceptable PowerShell version!"
}
