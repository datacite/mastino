variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "assets.datacite.org"
}

variable "vpc_id" {}

variable "lupo_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb"
}

variable "ttl" {
  default = "300"
}

variable "re3data_url" {
  default = "http://www.re3data.org/api/beta"
}
variable "bracco_url" {
  default = "https://doi.datacite.org"
}

variable "memcache_servers" {
  default = "memcached1.datacite.org:11211"
}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "session_encrypted_cookie_salt" {}
variable "bugsnag_key" {}
variable "mailgun_api_key" {}
variable "slack_webhook_url" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "datacite"
}
variable "mysql_host" {}
variable "es_host" {
  default = "elasticsearch.datacite.org"
}
variable "es_name" {
  default = "es"
}
variable "api_dns_name" {
  default = "api.datacite.org"
}

variable "handle_url" {}
variable "admin_username" {}
variable "admin_password" {}
