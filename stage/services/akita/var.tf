variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "ttl" {
  default = "300"
}

variable "public_key" {}

variable "vpc_id" {}
variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "akita_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "next_public_api_url" {
  default = "https://api.stage.datacite.org"
}

variable "next_public_profiles_url" {
  default = "https://profiles.stage.datacite.org"
}
variable "sitemaps_url" {
  default = "https://commons.stage.datacite.org"
}
variable "sitemaps_bucket_url" {
  default = "http://search.test.datacite.org.s3.amazonaws.com"
}
variable "next_public_jwt_public_key" {}
variable "sentry_dsn" {}
variable "namespace_id" {}
