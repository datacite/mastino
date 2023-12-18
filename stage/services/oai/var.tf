variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}

variable "viringo_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-stage"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "base_url" {
  default = "https://oai.stage.datacite.org/oai"
}

variable "api_url" {
  default = "http://client-api.stage.local"
}

variable "api_password" {}

variable "namespace_id" {}
variable "sentry_dsn" {}
variable "public_key" {}
