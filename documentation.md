# Documentation steps

This document is for detailed documentation of what has been tried and what has been implemented.

Work on this project before 2026-11-04 was entirely structural, like copying an old user import script form the WinServ course and writing the skeleton of the `README.md` file as well as `.gitignore`, and will be ignored in this document.

## 2026-11-04

This day was spent largely iterating through possible scopes for the project with help from Claude Code and looking up Terraform tutorials.

In the end, I landed on implementing an SFTP server, on my partners suggestion. This will have a real life use case when completed.

### createSFTPfolders.ps1

A PowerShell script to check if a test-folder exists (and create one if it doesn't) was written first. This instantly became obsolete after realising I can achieve the same effect with Terraform. File was not deleted on this day.

### Terraform basic setup + test-file

Basic setup and testing of the 4 basic terraform commands (`init, validate, plan & destroy`) was implemented. `local provider` + a resource that creates a test-file were implemented in `main.tf`.

`terraform.tfstate` & it's corresponding backup file were added to `.gitignore`.

Tried implementing a `provisioner` that deletes the folders that Terraform creates, but only ran into issues. There are ways to do this in `bash`, but I descided on only running PowerShell and Terraform for now. Might revisit if I get the project to a passing grade before the deadline.

### installOpenSSHServer.ps1 part 1

Found an MS Learn Guide at [this URL](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell&pivots=windows-11) for installing OpenSSH on Windows.

Also [this guide](https://woshub.com/installing-sftp-ssh-ftp-server-on-windows-server-2012-r2/) for installing SFTP on Windows.

Created the file and implemented if-statements to check the PowerShell version requirement as well as if the script is ran in an elevated shell. If requirements are not met, exits.

## 2026-11-05

### installOpenSSHServer.ps1 part 2

Added an if-statement in script to check whether OpenSSHServer was installed, and install if not.
