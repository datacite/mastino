variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "assets.test.datacite.org"
}
variable "vpc_id" {}

variable "sashimi_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "memcache_servers" {
  default = "memcached.test.datacite.org:11211"
}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "usage_url" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "metrics"
}
variable "mysql_host" {}
variable "public_key" {}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

 variable "namespace_id" {}

 variable "sentry_dsn" {}
