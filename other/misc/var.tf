variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "github_pages_records" {
  default = ["185.199.108.153","185.199.109.153","185.199.110.153","185.199.111.153"]
}

variable "ttl" {
    default = "300"
}

variable "siteground_ip_mdc_prod" {}