variable "mysql_host" {
  default = "mysql"
}

variable "mysql_port" {
  default = "3306"
}

variable "mysql_database" {
  default = "volpino"
}

variable "mysql_user" {
  default = "root"
}

variable "mysql_password" {
  default = ""
}

variable "mysql_allow_empty_password" {
  default = "yes"
}

variable "jwt_private_key" {
  default = "foo"
}

variable "jwt_public_key" {
  default = "bar"
}

variable "service_port" {
  default = "8080"
}

variable "secret_key_base" {
  default = "9d108dfe49484cd4698dd0ae8876e4bddf7c953c64285e1be23a059eabe629b6c62b1b5b12efcc20c98a3c9d89bfd9a8039a8859af7bc21ad222f9694ad4751a"
}
