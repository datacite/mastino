variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "assets.test.datacite.org"
}
variable "vpc_id" {}

variable "shiba-inu_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "bugsnag_key" {}
variable "resolution_index" {}
variable "es_host" {}
