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
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "memcache_servers" {
  default = "memcached.test.datacite.org:11211"
}
variable "api_dns_name" {
  default = "api.test.datacite.org"
}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "bugsnag_key" {}
variable "slack_webhook_url" {}

variable "volpino_url" {
  default = "https://profiles.test.datacite.org/api"
}
variable "lagottino_url" {
  default = "https://api.test.datacite.org"
}
variable "eventdata_url" {
  default = "https://bus-staging.eventdata.crossref.org"
}
variable "volpino_token" {}
variable "eventdata_token" {}
variable "lagottino_token" {}

variable "datacite_crossref_source_token" {}
variable "datacite_related_source_token" {}
variable "datacite_other_source_token" {}
