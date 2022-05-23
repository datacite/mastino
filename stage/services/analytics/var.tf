variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "vpc_id" {}
variable "public_key" {}
variable "lb_name" {
  default = "lb-stage"
}
variable "security_group_id" {}

variable "ttl" {
  default = "300"
}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "slack_webhook_url" {
  default = ""
}
variable "namespace_id" {}

variable "sentry_dsn" {}

variable "analytics_dns_name" {
  default = "analytics.stage.datacite.org"
}
variable "analytics_tags" {
  type = map(string)
}

variable "admin_user_pwd" {}
variable "admin_user_name" {}
variable "admin_user_email" {}

variable base_url {}

variable "database_url" {}

variable "clickhouse_database_url" {}
variable "clickhouse_database_user" {}
variable "clickhouse_database_password" {}

variable "smtp_host_port" {
  default = "25"
}
variable "smtp_retries" {
  default = "5"
}
variable "smtp_host_ssl_enabled" {
  default = "false"
}
variable "mailer_adapter" {
  default = "Bamboo.SMTPAdapter"
}

variable "postmark_api_key" {
  default = ""
}
variable "smtp_user_pwd" {}
variable "smtp_host_addr"  {}
variable "mailer_email" {}
variable "secret_key_base" {}
variable "smtp_user_name"  {}