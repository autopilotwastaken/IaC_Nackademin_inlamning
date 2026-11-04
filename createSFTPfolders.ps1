if (!(Test-Path ".\SFTP\")) {
    Write-Host "Folder .\SFTP\ does not exist, creating folder"
    New-Item -ItemType "Directory" -Path ".\SFTP\"
} else {
    Write-Host "Folder exists!"
}