provider "kubernetes" {
  version = "~> 1.0.1"
}

provider "external" {
  version    = "~> 1.0"
}

data "external" "repo" {
  program = ["ruby", "${path.module}/repo.rb"]
}
