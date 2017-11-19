variable "service-ports" {
  type    = "map"
  default = {
    "cheetoh" = "8070"
    "data" = "8021"
    "mysql" = "3306"
  }
}

variable "mysql-database" {
  default = "datacite"
}

variable "mysql-user" {
  default = "root"
}

variable "mysql-allow-empty-password" {
  default = "yes"
}
