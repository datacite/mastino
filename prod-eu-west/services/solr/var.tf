variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}
variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "ttl" {
  default = "300"
}

variable "search_tags" {
  type = "map"
}

variable "solr_user" {}
variable "solr_password" {}

variable "aws_route53_record_search_name" {
    default = "search.datacite.org"
}
