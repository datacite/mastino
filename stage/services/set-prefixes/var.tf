variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "security_group_id" {}
variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "host" {}
variable "username" {}
variable "password" {}

variable "client_created_path" {
    default = "/client-prefixes/set-created"
}
variable "client_provider_path" {
    default = "/client-prefixes/set-provider"
}
variable "provider_created_path" {
    default = "/provider-prefixes/set-created"
}
variable "client_test_prefix_path" {
    default = "/clients/set-test-prefix"
}
variable "provider_test_prefix_path" {
    default = "/providers/set-test-prefix"
}
