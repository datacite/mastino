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
  type = map(string)
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
variable "api_url" {
  default = "https://api.datacite.org"
}
variable "bracco_url" {
  default = "https://doi.datacite.org"
}

variable "memcache_servers" {
  default = "memcached1.datacite.org:11211"
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
variable "es_host" {
  default = "elasticsearch.datacite.org"
}
variable "es_name" {
  default = "es"
}
variable "api_dns_name" {
  default = "api.datacite.org"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "handle_url" {}
variable "handle_username" {}
variable "handle_password" {}
variable "admin_username" {}
variable "admin_password" {}

variable "namespace_id" {}
variable "jwt_blacklisted" {}

variable "api_aws_access_key" {}
variable "api_aws_secret_key" {}

variable "exclude_prefixes_from_data_import" {
  default = ""
}
variable "shoryuken_concurrency" {
  default = "30"
}
variable "metadata_storage_bucket_name" {
  default = ""
}
variable "passenger_max_pool_size" {
  default = "12"
}
variable "passenger_min_instances" {
  default = "5"
}
