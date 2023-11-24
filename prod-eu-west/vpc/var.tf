variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "vpc_id" {}

variable "security_group_public_id" {}
variable "security_group_private_id" {}
variable "subnet_datacite-public_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-public-alt_id" {}
variable "subnet_datacite-alt_id" {}

variable "ttl" {
  default = "300"
}

variable "test_prefix" {}

variable "mysql_host" {}
variable "mysql_database" {
  default = "datacite"
}
variable "mysql_user" {}
variable "mysql_password" {}

variable "search_tags" {
  type = map(string)
}

variable "dd_api_key" {}

variable "cluster" {
  default = "default"
}

variable "key_name" {}

variable "lb_name" {
  default = "lb"
}

variable "environment" {
  default = "prod"
}

variable "waf_ip_rate_limit" {}
variable "wafregional_rule_id" {}
variable "waf_regex_path_disallow_pattern_strings" {
  type = "list"
}
variable "waf_regex_host_allow_pattern_strings" {
  type = "list"
}

variable "waf_nat_ip" {}
variable "waf_whitelisted_ip" {}
variable "waf_blacklisted_ip" {}
