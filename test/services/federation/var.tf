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
  type = map(string)
}

variable "lb_name" {
  default = "lb-test"
}

variable "api_dns_name" {
  default = "api.test.datacite.org"
}

variable "profiles_url" {
  default = "https://api.test.datacite.org/profiles/graphql"
}
variable "client_api_url" {
  default = "https://api.test.datacite.org/client-api/graphql"
}
variable "api_url" {
  default = "https://api.test.datacite.org/api/graphql"
}
variable "strapi_url" {
  default = "https://strapi.test.datacite.org/graphql"
}

variable "sentry_dsn" {}
variable "namespace_id" {}
variable "apollo_api_key" {}
