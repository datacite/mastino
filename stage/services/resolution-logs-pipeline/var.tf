variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "assets.test.datacite.org"
}
variable "vpc_id" {}

variable "shiba-inu_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "jwt_public_key" {}
variable "jwt_private_key" {}
variable "bugsnag_key" {}
variable "es_index" {
  default = "resolutions"
}

variable "es_host" {
  default = "arn:aws:es:eu-west-1:404017989009:domain/elasticsearch-test"
}
variable "es_name" {
  default = "es"
}

variable "s3_merged_logs_bucket" {
  default = "merged-logs-bucket.stage.datacite.org"
}
variable "s3_resolution_logs_bucket" {
  default = "resolution-logs-bucket.stage.datacite.org"
}