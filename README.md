# SFTP Setup

## Explanation of how the project is assessed

This is an Examination project for the course IaC at Nackademin Oct-Nov 2026. The following sections explain what is expected for each passing grade.

## Goals

This project creates an SFTP server on my local computer. Users can be added and dynamically be given access to the main shared folder.

## Methodology

Terraform and PowerShell were used in this project.

Terraform creates the shared folder and generates a JSON file with usernames and chroot directories. It also deactivates sshd and its corresponding firewall rule on `destroy`. It uses `variables.tf` to define the format for variables in `terraform.tfvars`, which has dicts/maps of usernames and chroot directory paths to be sent to JSON upon `create`.

Powershell installs `OpenSSH Server`, starts the `sshd` service, creates a firewall rule to open port 22 to incoming traffic and starts it. If the firewall rule already exists but isn't active, it activates it. It then asks the user to imput a string, converting it to a secure string.

PowerShell then creates users based on JSON, using the secure string as passwords, gives users NTFS permissions to modify the shared folder and lastly injects `match user` blocks into `sshd_config` and restarts the `sshd` service.

## Results

After all code has ran, it allows 2 new users to sftp into the shared folder and modify the files in said folder. Code is only runnable once, users need to be manually removed, their permissions in shared folder need to be manually removed and `sshd_config` needs to be edited after every run.

## Reflection

Difficulty was had with orchestrating the entire flow via Terraform, which was given up on after discussion with the teacher. This flow does not have different passwords for different users, which is the most glaring fault and should be fixed at first opportunity if work continues on this project.

Unpacking values from JSON was easy and easily laborated into the code.

Adding a script to remove users, their NTFS permissions and their corresponding `match user` blocks from `sshd` should be added as a script to be run from a provisioner in `main.tf` as one of the next steps.

## Link to Github Repository

[Link to Github Repo](https://github.com/autopilotwastaken/IaC_Nackademin_inlamning)
