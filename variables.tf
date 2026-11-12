variable "users" {
  type      = map(string)   # username: chroot
  sensitive = false
}