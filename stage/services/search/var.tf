variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}

variable "doi-metadata-search_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "cdn_url" {
  default = "https://www.stage.datacite.org"
}
variable "homepage_url" {
  default = "https://www.stage.datacite.org"
}
variable "commons_url" {
  default = "https://commons.stage.datacite.org"
}
variable "orcid_url" {
  default = "https://sandbox.orcid.org"
}
variable "orcid_update_url" {
  default = "https://api.stage.datacite.org"
}
variable "volpino_url" {
  default = "https://api.stage.datacite.org"
}
variable "api_url" {
  default = "http://client-api.stage.local"
}
variable "jwt_host" {
  default = "https://profiles.stage.datacite.org"
}
variable "fabrica_url" {
  default = "https://doi.stage.datacite.org"
}
variable "sitemaps_url" {
  default = "https://search.stage.datacite.org"
}
variable "sitemaps_bucket_url" {
  default = "http://search.test.datacite.org.s3.amazonaws.com"
}
variable "data_url" {
  default = "https://api.stage.datacite.org"
}
variable "gabba_url" {
  default = "search.stage.datacite.org"
}

variable "memcache_servers" {
  default = "memcached.stage.datacite.org:11211"
}

variable "jwt_public_key" {}
variable "orcid_update_uuid" {}
variable "orcid_update_token" {}
variable "sentry_dsn" {}
variable "gabba_cookie" {}
variable "secret_key_base" {}
