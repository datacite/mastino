terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 2.70"
    }
  }

  required_version = ">= 1.6"

  cloud {
    organization = "datacite-ng"

    workspaces {
      name = "global-dns"
    }
  }
}