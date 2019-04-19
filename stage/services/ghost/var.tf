variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "lb_name" {
  default = "lb-stage"
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
  default = "ghost"
}
variable "mysql_host" {}

variable "url" {
  default = "https://ghost.test.datacite.org:2368"
}

variable "mailgun_user" {}
variable "mailgun_password" {}
