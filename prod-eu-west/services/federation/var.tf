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

variable "vaestgoetaspets_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb"
}

variable "api_dns_name" {
  default = "api.datacite.org"
}

variable "profiles_url" {
  default = "http://profiles.test.local/profiles/graphql"
}
variable "client_api_url" {
  default = "https://client-api.local/client-api/graphql"
}
variable "api_url" {
  default = "https://api.local/api/graphql"
}

variable "sentry_dsn" {}
variable "namespace_id" {}
variable "apollo_api_key" {}
