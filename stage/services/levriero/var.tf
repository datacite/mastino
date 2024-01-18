variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "levriero_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "memcache_servers" {
  default = "memcached.stage.datacite.org:11211"
}
variable "api_dns_name" {
  default = "api.stage.datacite.org"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "public_key" {}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "sentry_dsn" {}
variable "slack_webhook_url" {}

variable "volpino_url" {
  default = "https://api.stage.datacite.org"
}
variable "lagottino_url" {
  default = "http://client-api.stage.local"
}
variable "eventdata_url" {
  default = "https://bus-staging.eventdata.crossref.org"
}
variable "eventdata_token" {}
variable "staff_admin_token" {}
variable "staff_profiles_admin_token" {}

variable "datacite_crossref_source_token" {}
variable "datacite_related_source_token" {}
variable "datacite_other_source_token" {}
variable "datacite_url_source_token" {}
variable "datacite_arxiv_source_token" {}
variable "datacite_pmid_source_token" {}
variable "datacite_handle_source_token" {}
variable "datacite_igsn_source_token" {}
variable "datacite_funder_source_token" {}
variable "datacite_affiliation_source_token" {}
variable "datacite_usage_source_token" {}
variable "datacite_resolution_source_token" {}
variable "datacite_orcid_auto_update_source_token" {}
variable "crossref_orcid_auto_update_source_token" {}
variable "crossref_related_source_token" {}
variable "crossref_datacite_source_token" {}
variable "crossref_other_source_token" {}
variable "crossref_funder_source_token" {}
variable "crossref_import_source_token" {}
variable "orcid_affiliation_source_token" {}

variable "namespace_id" {}
