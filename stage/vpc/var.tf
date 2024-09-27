variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "vpc_id" {}
variable "ecs_ami" {
  type        = map(any)
  description = "Amazon Linux ECS-optimized AMI"

  default = {
    eu-west-1 = "ami-066826c6a40879d75"
    us-east-1 = "ami-07eb698ce660402d2"
  }
}
variable "security_group_public_id" {}
variable "security_group_private_id" {}
variable "subnet_datacite-public_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-public-alt_id" {}
variable "subnet_datacite-alt_id" {}

variable "ttl" {
  default = "300"
}

variable "mysql_host" {}
variable "mysql_database" {
  default = "datacite"
}
variable "mysql_user" {}
variable "mysql_password" {}

variable "cluster" {
  default = "stage"
}

variable "key_name" {}
variable "dd_api_key" {}

variable "lb_name" {
  default = "lb-stage"
}
