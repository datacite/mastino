terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 0.14"

  backend "atlas" {
    name         = "datacite-ng/global-dns"
  }
}