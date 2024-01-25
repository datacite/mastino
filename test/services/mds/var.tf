variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "poodle_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-test"
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

variable "realm" {
  default = "mds.test.datacite.org"
}

variable "sentry_dsn" {}

variable "api_url" {
  default = "http://client-api.test.local"
}
