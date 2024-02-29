variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "vpc_id" {}

variable "ami" {
  type = map(string)
  description = "Amazon Linux default AMI"

  default = {
    eu-west-1 = "ami-1a962263"
    us-east-1 = "ami-55ef662f"
  }
}

variable "hostname" {}
variable "key_name" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-public_id" {}

variable "ami_2024" {
  type = "map"
  description = "Amazon Linux 2024 AMI"

  default = {
    eu-west-1 = "ami-02cad064a29d4550c"
  }
}

variable "hostname_2024" {}
variable "key_name_2024" {}
