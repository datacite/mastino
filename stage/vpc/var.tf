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
    eu-west-1 = "ami-c91624b0"
    us-east-1 = "ami-5253c32d"
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

variable "cluster" {
  default = "stage"
}

variable "key_name" {}
variable "dd_api_key" {}
