variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "pekingese_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb"
}

variable "ttl" {
  default = "300"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}
variable "namespace_id" {}

variable "api_port" {}
variable "opensearch_host" {}
variable "opensearch_index" {}
