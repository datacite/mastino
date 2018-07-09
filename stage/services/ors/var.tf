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

variable "neo_user" {}
variable "neo_password" {}

variable "redis_url" {
   default = "redis://redis1.test.datacite.org:6379/6"
}

variable "neo_url" {
   default = "neo.test.datacite.org"
}

variable "proxy_url" {
   default = "ors.datacite.org"
}

variable "wsgi_dns" {
   default = "wsgi.test.datacite.org"
}
variable "wsgi_port" {
   default = "3031"
}
variable "bagit_dns" {
   default = "bagit.test.datacite.org"
}
variable "bagit_port" {
   default = "80"
}

variable "datacite_url" {
   default = "https://mds.test.datacite.org"
}
