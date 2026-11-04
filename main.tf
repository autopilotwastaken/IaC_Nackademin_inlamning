provider "local" {
  
}

resource "local_file" "test" {
  content = "This is a placeholder file generated in order to generate the file structure"
  filename = "${path.module}/shared/placeholder"
}