provider "local" {}

# create placeholder file
resource "local_file" "test" {
  content = "This is a placeholder file generated in order to generate the file structure"
  filename = "${path.module}/shared/placeholder"
}

# resource "local_file" "users_config" {
#   filename = "${path.module}/users.json"
#   content = 
# }

# runs script to install sshd
resource "terraform_data" "install_sshd" {
  provisioner "local-exec" {
    when = create
    command = "powershell.exe -ExecutionPolicy Bypass -File ./installOpenSSHServer.ps1"
    interpreter = ["PowerShell"]
  }
}

# deactivates sshd-in firewall rule
resource "terraform_data" "deactivate_sshd-in" {
  provisioner "local-exec" {
    when = destroy
    command = "Disable-NetFirewallRule 'sshd-in'"
    interpreter = ["PowerShell"]
  }
}

# stops sshd service
resource "terraform_data" "stop_sshd" {
  provisioner "local-exec" {
    when = destroy
    command = "Stop-Service 'sshd'"
    interpreter = ["PowerShell"]
  }
}


### TODO
# Create 2 users
# Make test script of one of the users uploading a file and then downloading it from SFTP server
# Write new script that consolidates stop_sshd and deactivate_sshd-in to one resource
