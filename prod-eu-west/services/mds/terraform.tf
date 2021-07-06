terraform {
  required_version = ">= 0.13"

  backend "atlas" {
    name         = "datacite-ng/prod-eu-west-services-mds"
  }
}
