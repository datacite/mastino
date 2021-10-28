variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "public_key" {}

variable "vpc_id" {}

variable "lb_name" {
  default = "lb-stage"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "namespace_id" {}


// FOR ECS/EC2/EBS and DOCKER REXRAY

variable "hostname" {}
variable "key_name" {}

variable "ami" {
  type = map(string)
  description = "Amazon Linux default AMI"

  default = {
    eu-west-1 = "ami-05cd35b907b4ffe77"
  }
}
