variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}

variable "oaip_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "solr_url" {
  default = "https://solr.datacite.org/"
}
variable "cdn_url" {
  default = "https://assets.datacite.org/"
}
