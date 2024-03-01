terraform {
  required_version = ">= 0.12"

  backend "atlas" {
    name         = "datacite-ng/eu-prod-west-services-repository-finder"
  }
}
