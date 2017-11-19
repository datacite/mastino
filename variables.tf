variable "service-ports" {
  type    = "map"
  default = {
    "cheetoh" = "8070"
    "data" = "8021"
  }
}
