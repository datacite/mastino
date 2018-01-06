provider "docker" {
  version    = "~> 0.1"
}

provider "external" {
  version    = "~> 1.0"
}

data "docker_registry_image" "volpino" {
  name = "datacite/volpino"
}

data "external" "repo" {
  program = ["ruby", "${path.module}/repo.rb"]
}
