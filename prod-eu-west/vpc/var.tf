variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "vpc_id" {}
variable "ecs_ami" {
  type = "map"
  description = "Amazon Linux ECS-optimized AMI"

  default = {
    eu-west-1 = "ami-0627e141ce928067c"
    us-east-1 = "ami-045f1b3f87ed83659"
  }
}
variable "security_group_public_id" {}
variable "security_group_private_id" {}
variable "subnet_datacite-public_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-public-alt_id" {}
variable "subnet_datacite-alt_id" {}

variable "ttl" {
  default = "300"
}

variable "solr_url" {
  default = "https://solr.datacite.org"
}
variable "solr_user" {}
variable "solr_password" {}
variable "solr_home" {
  default = "/data/solr"
}
variable "test_prefix" {}

variable "mysql_host" {}
variable "mysql_database" {
  default = "datacite"
}
variable "mysql_user" {}
variable "mysql_password" {}

variable "search_tags" {
  type = "map"
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
  default = "prod-eu-west"
}

variable "waf_ips_disallow" {
  type = "list"
}
variable "waf_ip_rate_limit" {
  type = "string"
}
variable "wafregional_rule_id" {}
variable "waf_regex_path_disallow_pattern_strings" {
  type = "list"
}
variable "waf_regex_host_allow_pattern_strings" {
  type = "list"
}
