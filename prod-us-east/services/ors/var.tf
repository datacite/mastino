variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
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
   default = "redis://redis1.us.datacite.org:6379/2"
}

variable "neo_url" {
   default = "neo.ors.local"
}

variable "proxy_url" {
   default = "ors.datacite.org"
}

variable "bagit_tags" {
  type = "map"
}

variable "wsgi_tags" {
  type = "map"
}

