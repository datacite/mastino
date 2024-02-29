variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "vpc_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-public_id" {}

variable "ami_2024" {
  type = map(string)
  description = "Amazon Linux 2024 AMI"

  default = {
    eu-west-1 = "ami-02cad064a29d4550c"
  }
}

variable "hostname_2024" {}
variable "key_name_2024" {}
