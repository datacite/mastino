variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "mailgun_api_key" {}
variable "slack_webhook_url" {
  default = ""
}
variable "smtp_host_port" {}
variable "clickhouse_database_url" {}
variable "clickhouse_database_user" {}
variable "clickhouse_database_password" {}
variable "admin_user_email" {}
variable "smtp_retries" {}
variable smtp_host_ssl_enabled {}
variable mailer_adapter {}
variable database_url {}
variable postmark_api_key {}
variable smtp_user_pwd {}
variable admin_user_pwd {}
variable smtp_host_addr  {}
variable admin_user_name {}
variable base_url {}
variable mailer_email {}
variable secret_key_base {}
variable smtp_user_name  {}

variable "vpc_id" {}

variable "analytics_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-stage"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "sentry_dsn" {}
variable "namespace_id" {}
variable "file_system_id" {}

variable "analytics_dns_name" {
  default = "analytics.stage.datacite.org"
}

variable "ttl" {
  default = "300"
}

variable geolite2_country_db  {}
variable geoipupdate_edition_ids  {}
variable geoipupdate_frequency  {}
variable geoipupdate_account_id  {}
variable geoipupdate_license_key  {}
variable "public_key" {}
