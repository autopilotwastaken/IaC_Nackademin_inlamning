# This script assumes you are running Win11 / WinServ22 (or newer)
# This script has to be run in an elevated (Run as Administrator) terminal!

# Setup logfile
if (!(Test-Path .\setup.log)) {
    New-Item -ItemType File -Name ".\setup.log"
}
$logPath = ".\setup.log"

# Logging function
function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet("INFO", "ERROR", "OK")]
        [string]$Level = "INFO"
    )
    
    # Logs say what machine + user wrote logs
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$(whoami)] [$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $logEntry
}

# taken from MS Learn, check if current user is Local Admin
$isLocalAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isLocalAdmin -ne $true) {
    Write-Host "Please run script as Administrator!"
    Write-Log "Tried to run installOpenSSHServer.ps1 without Admin Priv!" -Level ERROR
    Exit
} else {
    Write-Host "You are running as Admin!"
}

# Check PS version at least 5.0.0
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "Please run in PowerShell version 5 or higher!"
    Write-Log "Tried to run installOpenSSHServer.ps1 with outdated PowerShell version (less than 5)!" -Level ERROR
    Exit
} else {
    Write-Host "Acceptable PowerShell version!"
}

# Check if OpenSSH Server installed & install if not
$openSSHInstalled = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server~~~~0.0.1.0'
if ($openSSHInstalled.State -eq "NotPresent") {
    Write-Host "Installing OpenSSH Server!"
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Write-Log "Installed OpenSSH Server!" -Level OK
} else {
    Write-Host "OpenSSH Server is installed!"
}

# Start the sshd service
$sshdStatus = (Get-Service "sshd")
if ($sshdStatus.Status -eq "Stopped") {
    Write-Host "Starting Service: sshd"
    Start-Service sshd
    Write-Log "Started Service: sshd" -Level OK
} else {
    Write-Host "sshd service is already running!"
}

# OPTIONAL but recommended (taken from MS Learn guide, saving for future use)
# Set-Service -Name sshd -StartupType 'Automatic'

# Check SSH firewall rule + create 
if (!(Get-NetFirewallRule -Name "sshd-in" -ErrorAction SilentlyContinue)) {
    Write-Output "Making and starting Firewall Rule 'sshd-in'"
    New-NetFirewallRule -Name 'sshd-in' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    Write-Log "Made new Firewall Rule: sshd-in" -Level OK
} elseif ((Get-NetFirewallRule -Name "sshd-in" -ErrorAction SilentlyContinue).enabled -eq 'False') {
    Write-Output "Starting Firewall Rule 'sshd-in'"
    Set-NetFirewallRule -Name "sshd-in" -Enabled True
    Write-Log "Enabled Firewall Rule: sshd-in" -Level OK
} else {
    Write-Output "Firewall rule 'sshd-in' already exists and is Running"
}

# add SFTP config of users and their folder access either here or in separate file!