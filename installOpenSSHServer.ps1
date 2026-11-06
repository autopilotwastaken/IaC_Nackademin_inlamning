# This script assumes you are running Win11 / WinServ22 (or newer)
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

# Check if OpenSSH Server installed & install if not
$openSSHInstalled = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server~~~~0.0.1.0'
if ($openSSHInstalled.State -eq "NotPresent") {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "OpenSSH Server is installed!"
}

# Start the sshd service
$sshdStatus = (Get-Service "sshd")
if ($sshdStatus.Status -eq "Stopped") {
    Write-Host "Starting sshd service"
    Start-Service sshd
} else {
    Write-Host "sshd service is already running!"
}

# # OPTIONAL but recommended:
# Set-Service -Name sshd -StartupType 'Automatic'

# # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "sshd-in" -ErrorAction SilentlyContinue)) {
    Write-Output "Making and starting Firewall Rule 'sshd-in'"
    New-NetFirewallRule -Name 'sshd-in' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} elseif ((Get-NetFirewallRule -Name "sshd-in" -ErrorAction SilentlyContinue).enabled -eq 'False') {
    Write-Output "Starting Firewall Rule 'sshd-in'"
    Set-NetFirewallRule -Name "sshd-in" -Enabled True
} else {
    Write-Output "Firewall rule 'sshd-in' already exists and is Running"
}

