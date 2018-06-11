variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "vpc_id" {}

variable "ttl" {
  default = "300"
}

variable "lb_name" {
  default = "lb"
}

variable "main_id" {}
variable "main_private_ip" {}
