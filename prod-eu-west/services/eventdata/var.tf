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

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "bugsnag_key" {}
variable "mailgun_api_key" {}
variable "slack_webhook_url" {}

variable "librato_suites" {
  default = "rails_controller,rails_status,rails_cache,rails_job,rails_sql,rack"
}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "lagotto"
}
variable "mysql_host" {}
