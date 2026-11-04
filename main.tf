provider "local" {}

resource "local_file" "test" {
  content = "This is a placeholder file generated in order to generate the file structure"
  filename = "${path.module}/shared/placeholder"

#     # makes sure files are gone before "remove_folders" runs during "destroy"
#    depends_on = [terraform_data.remove_folders]
}

# resource "terraform_data" "remove_folders" {
#   provisioner "local-exec" {
#     when = destroy
#     command = "Remove-Item ${path.module}/shared"
#   }
# }