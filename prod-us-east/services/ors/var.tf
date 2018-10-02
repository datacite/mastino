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
   default = "redis://redis1.us.datacite.org:6379/6"
}

variable "neo_url" {
   default = "neo.datacite.org"
}

variable "proxy_url" {
   default = "ors.datacite.org"
}


variable "login_url" {
   default = "https://ors.datacite.org/login"
}

variable "datacite_url" {
   default = "https://mds.datacite.org"
}

variable "root_url" {
   default = "https://ors.datacite.org"
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

variable "indexd_url" {
   default = "indexd.datacite.org"
}
variable "indexd_username" {}
variable "indexd_password" {}

variable "bugsnag_key" {
   default = "2c30fce5bccd2542eba01246b6983049"
}
