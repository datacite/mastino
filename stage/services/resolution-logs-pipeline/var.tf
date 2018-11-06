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
variable "resolution_index" {
  default = "resolutions"
}
variable "es_host" {}

variable "es_host" {
  default = "elasticsearch.test.datacite.org"
}
variable "es_name" {
  default = "es"
}