variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "alopekis_tags" {
  type = map(string)
}

variable "lb_name" {
  default = "lb"
}

variable "ttl" {
  default = "300"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}
variable "namespace_id" {}

variable "opensearch_host" {}
variable "opensearch_port" {}

variable "opensearch_index" {
    default = "dois"
}

variable "output_path" {
    default = "/data"
}

variable "workers" {
    default = "16"
}

variable "datafile_bucket" {
    default = "datafile"
}

variable "log_bucket" {
    default = "datafile-logs"
}

variable "alopekis_aws_access_key" {}
variable "alopekis_aws_secret_key" {}