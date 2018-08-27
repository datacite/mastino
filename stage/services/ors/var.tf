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


variable "wsgi_tags" {
  type = "map"
}

variable "bagit_tags" {
  type = "map"
}

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

variable "globus_client" {}

variable "globus_username" {}
variable "globus_secret" {}

variable "bugsnag_key" {
   default = "2c30fce5bccd2542eba01246b6983049"
}

variable "indexd_url" {
   default = "https://indexd.ors.test.datacite.org"
}
variable "indexd_username" {}
variable "indexd_password" {}
