provider "local" {}

# create placeholder file
resource "local_file" "test" {
  content = "This is a placeholder file generated in order to generate the file structure"
  filename = "${path.module}/sftp/shared/.keep"
}

resource "local_sensitive_file" "users" {
  filename = "${path.module}/users.json"
  content = jsonencode([
    for u, c in var.users : { name = u, chroot = c }
  ])
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
