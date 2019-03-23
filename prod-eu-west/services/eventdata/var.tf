variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "assets.datacite.org"
}

variable "vpc_id" {}

variable "lagottino_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb"
}

variable "ttl" {
  default = "300"
}

variable "memcache_servers" {
  default = "memcached1.datacite.org:11211"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "public_key" {}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "sentry_dsn" {}
variable "mailgun_api_key" {}
variable "slack_webhook_url" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "lagotto"
}
variable "mysql_host" {}

variable "es_host" {
  default = "elasticsearch.datacite.org"
}
variable "es_name" {
  default = "es"
}

variable "namespace_id" {}
