variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "s3_bucket" {
  default = "assets.test.datacite.org"
}

variable "vpc_id" {}

variable "volpino_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "search_url" {
  default = "https://search.stage.datacite.org"
}
variable "orcid_url" {
  default = "https://sandbox.orcid.org"
}
variable "orcid_api_url" {
  default = "https://api.sandbox.orcid.org"
}
variable "commons_url" {
  default = "https://commons.stage.datacite.org"
}
variable "api_url" {
  default = "http://client-api.stage.local"
}
variable "cdn_url" {
  default = "https://assets.stage.datacite.org"
}
variable "blog_url" {
  default = "https://blog.stage.datacite.org"
}
variable "homepage_url" {
  default = "https://www.stage.datacite.org"
}

variable "redis_url" {}
variable "memcache_servers" {
  default = "memcached.stage.datacite.org:11211"
}

variable "log_level" {
  default = "warn"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "public_key" {}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "sentry_dsn" {}
variable "orcid_update_uuid" {}
variable "orcid_token" {}
variable "secret_key_base" {}
variable "github_personal_access_token" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "profiles"
}
variable "mysql_host" {}

variable "orcid_client_id" {}
variable "orcid_client_secret" {}
variable "github_client_id" {}
variable "github_client_secret" {}
variable "globus_client_id" {}
variable "globus_client_secret" {}

variable "namespace_id" {}

variable "es_host" {}
variable "es_scheme" {
  default = "https"
}
variable "es_port" {}
variable "es_name" {
  default = "es"
}
variable "es_prefix" {
  default = "stage"
}
variable "elastic_password" {}
