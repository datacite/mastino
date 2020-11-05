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

variable "akita_tags" {
  type = map
}

variable "lb_name" {
  default = "lb"
}

variable "next_public_api_url" {
  default = "https://api.datacite.org"
}
variable "next_public_profiles_url" {
  default = "https://profiles.datacite.org"
}
variable "sitemaps_url" {
  default = "https://commons.datacite.org"
}
variable "sitemaps_bucket_url" {
  default = "http://commons.datacite.org.s3.amazonaws.com"
}
variable "next_public_jwt_public_key" {}
variable "next_public_ga_tracking_id" {}
variable "sentry_dsn" {}
variable "namespace_id" {}
variable "public_key" {}
