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

  required_version = ">= 0.13"

  backend "atlas" {
    name = "datacite-ng/test-vpc"
  }
}
