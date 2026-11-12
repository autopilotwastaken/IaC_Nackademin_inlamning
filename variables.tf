variable "users" {
  type      = map(string)   # username: password
  sensitive = false
}