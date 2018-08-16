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


// uwsgi container variables

variable "neo_user" {}
variable "neo_password" {}

variable "redis_url" {
   default = "redis://redis1.test.datacite.org:6379/6"
}

variable "neo_url" {
   default = "neo.test.datacite.org"
}

variable "proxy_url" {
   default = "ors.test.datacite.org"
}

variable "datacite_url" {
   default = "https://mds.test.datacite.org"
}

variable "login_url" {
   default = "https://ors.test.datacite.org/login"
}



variable "ezid_user" {}
variable "ezid_password" {}

variable "datacite_user" {}
variable "datacite_password" {}

variable "admin_username" {}
variable "admin_password" {}
