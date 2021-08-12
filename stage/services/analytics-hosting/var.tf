variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "analytics-hosting_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb-stage"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "sentry_dsn" {}
variable "mailgun_api_key" {}
variable "slack_webhook_url" {
  default = ""
}
variable "namespace_id" {}

variable "analytics-hosting_dns_name" {
  default = "analytics-hosting.stage.datacite.org"
}

variable "ttl" {
  default = "300"
}