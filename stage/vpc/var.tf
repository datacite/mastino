variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "vpc_id" {}
variable "ecs_ami" {
  type = "map"
  description = "Amazon Linux ECS-optimized AMI"

  default = {
    eu-west-1 = "ami-4cbe0935"
    us-east-1 = "ami-fad25980"
  }
}
variable "security_group_id" {}
variable "subnet_datacite-private_id" {}

variable "ttl" {
  default = "300"
}

variable "lb_tg_arn" {}
variable "lb_tg_name" {}
