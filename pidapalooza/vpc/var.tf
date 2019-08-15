variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "name_servers" {
    type = "map"
    default = [
        "ns6.wixdns.net",
        "ns7.wixdns.net"
    ]
  }
}
