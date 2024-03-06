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
  type = map(string)
}

variable "lb_name" {
  default = "lb-test"
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

variable "memcache_servers" {
  default = "memcached.stage.datacite.org:11211"
}

variable "public_key" {}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "session_encrypted_cookie_salt" {}
variable "sentry_dsn" {}
variable "mailgun_api_key" {}
variable "slack_webhook_url" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "datacite"
}
variable "mysql_host" {}
variable "es_host" {}
variable "es_scheme" {
  default = "https"
}
variable "es_port" {}
variable "es_name" {
  default = "es"
}
variable "es_prefix" {
  default = ""
}
variable "elastic_password" {}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "api_dns_name" {
  default = "api.test.datacite.org"
}
variable "handle_url" {}
variable "handle_username" {}
variable "handle_password" {}
variable "admin_username" {}
variable "admin_password" {}

variable "namespace_id" {}
variable "oidc_client_id" {}
variable "oidc_client_secret" {}
variable "jwt_blacklisted" {}
variable "plugin_openapi_url" {
  default = "https://api.test.datacite.org"
}
variable "plugin_manifest_url" {
  default = "https://api.test.datacite.org"
}

variable "api_aws_access_key" {}
variable "api_aws_secret_key" {}