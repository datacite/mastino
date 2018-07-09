variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "lb_name" {
  default = "lb-us"
}

variable "ttl" {
  default = "300"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "neo_user" {}
variable "neo_password" {}


variable "redis_url" {
   default = "redis1.us.datacite.org"
}

variable "neo_url" {
   default = "neo.ors.local"
}

variable "proxy_url" {
   default = "ors.datacite.org"
}

