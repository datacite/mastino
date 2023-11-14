terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 2.70"
    }
  }

  required_version = ">= 1.14"

  backend "atlas" {
    name         = "datacite-ng/global-dns"
  }
}