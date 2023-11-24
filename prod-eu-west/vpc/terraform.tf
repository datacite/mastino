terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 2.7"
    }
    template = {
      source = "hashicorp/template"
    }
  }

 required_version = ">= 1.6"

  cloud {
    organization = "datacite-ng"

    workspaces {
      name = "prod-eu-west-vpc"
    }
  }
}
