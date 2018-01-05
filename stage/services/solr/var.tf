variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
/* variable "vpc_id" {} */
variable "ttl" {
  default = "300"
}
variable "lb_arn" {}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "solr_user" {}
variable "solr_password" {}

/* variable "listener_arn" {
  type = "string"
} */
