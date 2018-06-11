variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "assets.test.datacite.org"
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

variable "re3data_url" {
  default = "http://www.re3data.org/api/beta"
}
variable "app_url" {
  default = "https://app.test.datacite.org"
}
variable "volpino_url" {
  default = "https://profiles.test.datacite.org/api"
}

variable "memcache_servers" {
  default = "memcached.test.datacite.org:11211"
}

variable "es_host" {
  default = "elasticsearch.test.datacite.org"
}


variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "bugsnag_key" {}