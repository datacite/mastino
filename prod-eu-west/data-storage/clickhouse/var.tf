variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "public_key" {}

variable "vpc_id" {}

variable "lb_name" {
  default = "lb"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "namespace_id" {}

variable "key_name" {}

variable "ami" {
  type = map(string)
  description = "Amazon Linux default AMI"

  default = {
    eu-west-1 = "ami-06c11ea68c61e5570"
  }
}

variable "datacite_clickhouse_password" {}
