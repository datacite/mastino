variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "assets.test.datacite.org"
}

variable "vpc_id" {}

variable "lupo_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "re3data_url" {
  default = "http://www.re3data.org/api/beta"
}
variable "bracco_url" {
  default = "https://doi.test.datacite.org"
}
variable "levriero_url" {
  default = "https://api.test.datacite.org"
}

variable "memcache_servers" {
  default = "memcached.test.datacite.org:11211"
}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "secret_key_base" {}
variable "session_encrypted_cookie_salt" {}
variable "bugsnag_key" {}
variable "mailgun_api_key" {}
variable "slack_webhook_url" {}

variable "librato_suites" {
  default = "rails_controller,rails_status,rails_cache,rails_job,rails_sql,rack"
}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "datacite"
}
variable "mysql_host" {}
