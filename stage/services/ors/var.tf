variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "neo_password" {
   default = "nihdc_ors"
}

variable "neo_url" {
   default = "neo.ors.local"
}

variable "neo_user" {
   default = "neo4j"
}

variable "proxy_url" {
   default = "https://ezid.cdlib.org/id/"
}
