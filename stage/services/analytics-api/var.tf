variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "keeshond_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "ttl" {
  default = "300"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}
variable "namespace_id" {}

variable "datacite_api_url" {
    default = "https://api.stage.datacite.org"
}
variable "plausible_url" {
    default = "http://analytics.stage.local:8000"
}

variable "database_dbname" {
    default = "analytics_events_db"
}

variable "database_host" {
    default = "clickhouse.stage.local"
}

variable "database_user" {
    default = "admin"
}

variable "database_password" {}