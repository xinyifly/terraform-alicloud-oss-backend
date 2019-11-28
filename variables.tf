variable "region" {}

variable "scope" {}
variable "name" {
  default = ""
}

variable "create_oss_bucket" {
  default = true
}
variable "create_ots_instance" {
  default = true
}
