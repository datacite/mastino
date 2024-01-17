variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}

variable "content-negotiation_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-stage"
}

variable "lb_name_crosscite" {
  default = "crosscite-stage"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "memcache_servers" {
  default = "memcached.stage.datacite.org:11211"
}

variable "namespace_id" {}
variable "sentry_dsn" {}
variable "public_key" {}

variable "api_url" {
  default = "http://client-api.stage.local"
}
