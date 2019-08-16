variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "ttl" {
  default = "300"
}

variable "orcid_url" {
  default = "https://sandbox.orcid.org"
}
variable "api_url" {
  default = "https://api.test.datacite.org"
}
variable "eventdata_url" {
  default = "https://api.test.datacite.org"
}
variable "search_url" {
  default = "https://search.test.datacite.org"
}
variable "cdn_url" {
  default = "https://assets.test.datacite.org"
}

variable "content-negotiation_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "jwt_public_key" {}
variable "sentry_dsn" {}
variable "tracking_id" {}
