resource "random_string" "firstpart" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "secondpart" {
  length  = 16
  special = false
  upper   = false
}
