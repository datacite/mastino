variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "slack_icon_url" {
    default = "https://github.com/datacite/segugio/blob/master/source/images/fabrica.png"
}

variable "host" {}
variable "username" {}
variable "password" {}
variable "client_id" {}
variable "client_secret" {}
variable "slack_webhook_url" {}
variable "datacite_api_url" {}
variable "datacite_username" {}
variable "datacite_password" {}
