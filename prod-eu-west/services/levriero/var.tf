variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "levriero_tags" {
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
variable "api_dns_name" {
  default = "api.datacite.org"
}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "bugsnag_key" {}
variable "slack_webhook_url" {}

variable "solr_url" {
  default = "https://solr.datacite.org"
}
variable "volpino_url" {
  default = "https://profiles.datacite.org/api"
}
variable "crossref_query_url" {
  default = "https://api.eventdata.crossref.org"
}
variable "api_url" {
  default = "https://api.datacite.org"
}
variable "lagottino_url" {
  default = "https://api.datacite.org"
}
variable "eventdata_url" {
  default = "https://bus.eventdata.crossref.org"
}
variable "volpino_token" {}
variable "eventdata_token" {}
variable "lagottino_token" {}

variable "datacite_crossref_source_token" {}
variable "datacite_related_source_token" {}
variable "datacite_other_source_token" {}
variable "datacite_url_source_token" {}
variable "datacite_funder_source_token" {}