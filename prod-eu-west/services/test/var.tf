variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "lb_name" {
  default = "lb"
}

variable "ttl" {
  default = "300"
}
