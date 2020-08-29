variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "public_key" {}

variable "lb_name" {
  default = "lb"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "strapi"
}
variable "mysql_host" {}

variable "namespace_id" {}
variable "file_system_id" {}

variable "vers" {
  default = "3.1.4"
}