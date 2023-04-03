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

variable "analytics_database_dbname" {
    default = "analytics_events_db"
}

variable "analytics_database_host" {
    default = "clickhouse.stage.local"
}

variable "analytics_database_user" {
    default = "admin"
}

variable "analytics_database_password" {
    default = ""
}

variable "datacite_jwt" {}

variable "analytics_queue" {
    default = "stage_analytics"
}

variable "datacite_api_url" {
    default = "https://api.stage.datacite.org"
}

variable "api_username" {}
variable "api_password" {}