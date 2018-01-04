variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "ttl" {
  default = "300"
}

variable "cloudfront_alias_zone_id" {
  description = "Fixed hardcoded constant zone_id that is used for all CloudFront distributions"
  default     = "Z2FDTNDATAQYW2"
}
