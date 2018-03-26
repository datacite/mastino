variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}

variable "ttl" {
  default = "300"
}

variable "redis_host" {
  default = "redis1.test.datacite.org"
}


