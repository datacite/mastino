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
    "lupo" = "datacite"
    "profiles" = "profiles"
    "solr" = "datacite"
  }
}

variable "mysql-host" {
  default = "mysql"
}

variable "mysql-user" {
  default = "root"
}

variable "mysql-password" {
  default = ""
}

variable "mysql-allow-empty-password" {
  default = "yes"
}
