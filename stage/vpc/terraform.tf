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
  required_version = ">= 0.14"

  backend "atlas" {
    name = "datacite-ng/stage-vpc"
  }
}
