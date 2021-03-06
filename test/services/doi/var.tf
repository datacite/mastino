variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "ttl" {
  default = "300"
}

variable "vpc_id" {}
variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

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
  default = "https://www.stage.datacite.org"
}

variable "bracco_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-test"
}

variable "alb_public_key" {}
variable "jwt_public_key" {}
variable "sentry_dsn" {}
variable "tracking_id" {}
variable "public_key" {}
variable "namespace_id" {}
variable "oidc_client_id" {}
variable "oidc_client_secret" {}
variable "jwt_blacklisted" {}
