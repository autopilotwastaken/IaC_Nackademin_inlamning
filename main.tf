provider "local" {}

# create placeholder file
resource "local_file" "test" {
  content = "This is a placeholder file generated in order to generate the file structure"
  filename = "${path.module}/shared/placeholder"

    # makes sure files are gone before "remove_folders" runs during "destroy"
  depends_on = [terraform_data.remove_folders]
}

# runs script to install sshd
resource "terraform_data" "install_sshd" {
  provisioner "local-exec" {
    when = create
    command = "powershell.exe -ExecutionPolicy Bypass -File ./installOpenSSHServer.ps1"
    interpreter = ["PowerShell"]
  }
}

# removes generated folders when destroying
resource "terraform_data" "remove_folders" {
  provisioner "local-exec" {
    when = destroy
    command = "Remove-Item ${path.module}/shared"
    interpreter = ["PowerShell"]
  }
}

# deactivates sshd-in firewall rule
resource "terraform_data" "deactivate_sshd" {
  provisioner "local-exec" {
    when = destroy
    command = "Disable-NetFirewallRule 'sshd-in'"
    interpreter = ["PowerShell"]
  }
}
