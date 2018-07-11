variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}

variable "http-redirect_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}
