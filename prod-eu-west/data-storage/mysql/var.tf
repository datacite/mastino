variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-public_id" {}
variable "subnet_datacite-public-alt_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}