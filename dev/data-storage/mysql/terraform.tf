terraform {
  required_version = ">= 0.11"

  backend "local" {
    path = "../../terraform.tfstate"
  }
}
