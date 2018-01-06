provider "docker" {
  version    = "~> 0.1"
}

provider "external" {
  version    = "~> 1.0"
}

data "docker_registry_image" "lupo" {
  name = "datacite/lupo"
}

data "external" "repo" {
  program = ["ruby", "${path.module}/repo.rb"]
}
