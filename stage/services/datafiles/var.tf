variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "tesem_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "database_url" {}

variable "jwt_secret_key" {}
variable "tesem_secret_key" {}

variable "sentry_dsn" {}
variable "mailgun_api_key" {}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "dns_name" {
  default = "datafiles.stage.datacite.org"
}
