variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "ttl" {
    default = "300"
}

variable "vpc_id" {}
variable "vpc_id_us" {}

variable "changelog_dns_name" {}
variable "support_dns_name" {}
variable "design_dns_name" {}
variable "status_dns_name" {}

variable "dkim_record" {}
variable "dmarc_record" {}
variable "google_site_verification_record" {}
variable "ms_record" {}
variable "verification_record" {}
variable "dkim_salesforce" {}
variable "dkim_alt_salesforce" {}
variable "dkim_cm" {}

variable "siteground_ip_stage" {}
variable "siteground_ip_prod" {}
variable "siteground_ip_homepage_prod" {}
variable "siteground_ip_mdc_prod" {}