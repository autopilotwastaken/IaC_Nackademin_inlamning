# This script assumes you are running Win11 / WinServ22 (or newer)
# This script has to be run in an elevated (Run as Administrator) terminal!
import-module microsoft.powershell.localaccounts # needed for managing local users in PS7

# taken from MS Learn, check if current user is Local Admin
$isLocalAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isLocalAdmin -ne $true) {
    Write-Host "Please run script as Administrator!"
    Exit
} else {
    Write-Host "You are running as Admin!"
}

# Check PS version exactly 5.1
if ($PSVersionTable.PSVersion -contains '5.1.') {
    Write-Host "Please run in PowerShell version 5.1!"
    Exit
} else {
    Write-Host "Acceptable PowerShell version!"
}

# Check if OpenSSH Server installed & install if not
$openSSHInstalled = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server~~~~0.0.1.0'
if ($openSSHInstalled.State -eq "NotPresent") {
    Write-Host "Installing OpenSSH Server!"
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "OpenSSH Server is installed!"
}

# Start the sshd service
$sshdStatus = (Get-Service "sshd")
if ($sshdStatus.Status -eq "Stopped") {
    Write-Host "Starting Service: sshd"
    Start-Service sshd
} else {
    Write-Host "sshd service is already running!"
}

# Check SSH firewall rule + create 
if (!(Get-NetFirewallRule -Name "sshd-in" -ErrorAction SilentlyContinue)) {
    Write-Output "Making and starting Firewall Rule 'sshd-in'"
    New-NetFirewallRule -Name 'sshd-in' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} elseif ((Get-NetFirewallRule -Name "sshd-in" -ErrorAction SilentlyContinue).enabled -eq 'False') {
    Write-Output "Starting Firewall Rule 'sshd-in'"
    Set-NetFirewallRule -Name "sshd-in" -Enabled True
} else {
    Write-Output "Firewall rule 'sshd-in' already exists and is Running"
}

# Create new user for SFTP
$json = Get-Content -Path .\users.json | ConvertFrom-Json
foreach ($account in $json) {
    $userExist = Get-LocalUser $account.name -ErrorAction SilentlyContinue
    if ($null -eq $userExist) {
        Write-Host "Creating user $($account.name)"
        New-LocalUser -Name $account.name -NoPassword
    } else {
        Write-Host "User $($account.name) already exists!" 
    }
}

# Give users Modify Permissions in Shared folder
foreach ($account in $json) {
    $userExist = Get-LocalUser $account.name -ErrorAction SilentlyContinue
    if ($null -ne $userExist) {
        icacls ".\sftp\shared" /grant "$($env:COMPUTERNAME)\$($account.name):M"
    } else {
        Write-Host "User $($account.name) doesn't exist!" 
    }
}

# Append to C:\ProgramData\ssh\sshd_config:
# Match User $($account.name)
#     ForceCommand internal-sftp
#     ChrootDirectory $PSScriptRoot$($account.chroot)/$($account.name)
#     PasswordAuthentication yes
