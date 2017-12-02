variable "service-ports" {
  type    = "map"
  default = {
    "api" = "8017"
    "cheetoh" = "8070"
    "data" = "8021"
    "mysql" = "3306"
    "profiles" = "8080"
    "solr" = "8012"
  }
}

variable "mysql-databases" {
  type    = "map"
  default = {
    "profiles" = "profiles"
    "solr" = "datacite"
  }
}

variable "mysql_host" {
  default = "mysql"
}

variable "mysql_port" {
  default = "3306"
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
