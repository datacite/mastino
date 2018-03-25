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
    eu-west-1 = "ami-4cbe0935"
    us-east-1 = "ami-fad25980"
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
  default = "https://solr.test.datacite.org"
}
variable "solr_user" {}
variable "solr_password" {}
variable "solr_home" {
  default = "/data/solr"
}

variable "mysql_host" {}
variable "mysql_database" {
  default = "datacite"
}
variable "mysql_user" {}
variable "mysql_password" {}

variable "search_tags" {
  type = "map"
}

variable "syslog_host" {}
variable "syslog_port" {}

variable "cluster" {
  default = "test"
}

variable "key_name" {}

variable "lb_tg_api-stage" {
  default = "api-stage"
}

variable "lb_tg_http-redirect-stage" {
  default = "http-redirect-stage"
}
