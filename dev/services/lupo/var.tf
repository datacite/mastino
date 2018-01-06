variable "mysql_host" {
  default = "mysql"
}

variable "mysql_port" {
  default = "3306"
}

variable "mysql_database" {
  default = "lupo"
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

variable "solr-url" {
  default = "solr/api"
}

variable "jwt_private_key" {
  default = "foo"
}

variable "jwt_public_key" {
  default = "bar"
}

variable "service_port" {
  default = "8060"
}
