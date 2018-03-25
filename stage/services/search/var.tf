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

variable "ttl" {
  default = "300"
}

variable "cdn_url" {
  default = "https://assets.test.datacite.org/api"
}
variable "orcid_url" {
  default = "https://sandbox.orcid.org"
}
variable "orcid_update_url" {
  default = "https://profiles.test.datacite.org"
}
variable "api_url" {
  default = "https://api.test.datacite.org"
}
variable "data_url" {
  default = "https://data.test.datacite.org"
}
variable "gabba_url" {
  default = "search.test.datacite.org"
}

variable "memcache_servers" {
  default = "memcached.test.datacite.org:11211"
}

variable "jwt_public_key" {}
variable "orcid_update_uuid" {}
variable "orcid_update_token" {}
variable "bugsnag_key" {}
variable "bugsnag_js_key" {}
variable "gabba_cookie" {}
variable "secret_key_base" {}
