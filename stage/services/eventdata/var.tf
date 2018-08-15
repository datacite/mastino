variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "assets.test.datacite.org"
}

variable "vpc_id" {}

variable "lagottino_tags" {
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
variable "bugsnag_key" {}
variable "mailgun_api_key" {}
variable "slack_webhook_url" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "lagotto"
}
variable "mysql_host" {}

variable "es_host" {
  default = "elasticsearch.test.datacite.org"
}
variable "es_name" {
  default = "es"
}