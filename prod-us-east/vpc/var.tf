variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "us-east-1"
}
variable "vpc_id" {}

variable "security_group_public_id" {}
variable "security_group_private_id" {}
variable "subnet_datacite-public_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-public-alt_id" {}
variable "subnet_datacite-alt_id" {}

variable "ttl" {
  default = "300"
}

variable "cluster" {
  default = "us"
}
