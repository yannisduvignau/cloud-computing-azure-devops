resource "random_string" "main" {
  length  = 4
  special = false
  upper   = false
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

resource "random_password" "secret" {
  length  = 32
  special = true
}