variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "events_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "api_dns_name" {
  default = "events.stage.datacite.org"
}

variable "namespace_id" {}
variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "public_key" {}

variable "sentry_dsn" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {
  default = "datacite"
}
variable "mysql_host" {}

variable "es_host" {}
variable "es_scheme" {
  default = "https"
}
variable "es_port" {}
variable "es_name" {
  default = "es"
}
variable "es_prefix" {
  default = "stage"
}
variable "elastic_password" {}
