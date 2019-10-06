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
  default = "lb"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "cdn_url" {
  default = "https://assets.datacite.org"
}
variable "orcid_url" {
  default = "https://orcid.org"
}
variable "orcid_update_url" {
  default = "https://api.datacite.org"
}
variable "volpino_url" {
  default = "https://api.datacite.org"
}
variable "api_url" {
  default = "https://api.datacite.org"
}
variable "fabrica_url" {
  default = "https://doi.datacite.org"
}
variable "sitemaps_url" {
  default = "https://search.datacite.org"
}
variable "sitemaps_bucket_url" {
  default = "http://search.datacite.org.s3.amazonaws.com"
}
variable "data_url" {
  default = "https://api.datacite.org"
}
variable "gabba_url" {
  default = "search.datacite.org"
}

variable "memcache_servers" {
  default = "memcached1.datacite.org:11211"
}

variable "jwt_public_key" {}
variable "orcid_update_uuid" {}
variable "orcid_update_token" {}
variable "sentry_dsn" {}
variable "gabba_cookie" {}
variable "secret_key_base" {}
