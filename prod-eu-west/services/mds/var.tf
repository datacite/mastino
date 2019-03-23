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
  default = "lb"
}

variable "main_id" {}
variable "main_private_ip" {}

variable "mds_ami" {}
variable "key_name" {}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "poodle_tags" {
  type = "map"
}

variable "memcache_servers" {
  default = "memcached1.datacite.org:11211"
}

variable "sentry_dsn" {}
