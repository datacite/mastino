variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "changelog_dns_name" {}
variable "support_dns_name" {}
variable "status_dns_name" {}

variable "dkim_record" {}
variable "dmarc_record" {}
variable "google_site_verification_record" {}
variable "ms_record" {}
variable "verification_record" {}