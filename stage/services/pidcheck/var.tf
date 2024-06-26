variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}


variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "redis_host" {
  default = "redis1.test.datacite.org"
}
variable "pidcheck_tags" {
  type = map(string)
}

