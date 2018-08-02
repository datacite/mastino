variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "vpc_id" {}

variable "ttl" {
  default = "300"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "compose_id" {}


variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}


variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_host" {}

variable "handle_svr_private_key" {}
variable "handle_svr_public_key" {}