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

variable "public_key" {}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "sentry_dsn" {}
variable "slack_webhook_url" {}
variable "volpino_url" {
  default = "http://profiles.local"
}
variable "crossref_query_url" {
  default = "https://api.eventdata.crossref.org"
}
variable "api_url" {
  default = "http://client-api.local"
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
variable "datacite_affiliation_source_token" {}
variable "datacite_orcid_auto_update_source_token" {}
variable "crossref_orcid_auto_update_source_token" {}
variable "crossref_related_source_token" {}
variable "crossref_datacite_source_token" {}
variable "crossref_other_source_token" {}
variable "datacite_resolution_source_token" {}
variable "datacite_usage_source_token" {}
variable "orcid_affiliation_source_token" {}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "namespace_id" {}
