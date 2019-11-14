variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}

variable "content-negotiation_tags" {
  type = "map"
}

variable "lb_name" {
  default = "crosscite"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "memcache_servers" {
  default = "memcached1.datacite.org:11211"
}

variable "sentry_dsn" {}
variable "namespace_id" {}
variable "public_key" {}

variable "api_url" {
  default = "http://client-api.test.local"
}
