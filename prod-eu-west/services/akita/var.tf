variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "ttl" {
  default = "300"
}

variable "vpc_id" {}
variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "akita_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb"
}

variable "next_public_title" {
  default = "DataCite Commons"
}

variable "next_public_api_url" {
  default = "https://api.datacite.org"
}

variable "sentry_dsn" {}
variable "tracking_id" {}
variable "namespace_id" {}