variable "github_token" {}
variable "github_organization" {}
variable "github_repositories" {
  type    = "list"
  default = [
    "blog",
    "bolognese",
    "bolognese-bau",
    "cheetoh",
    "datacite",
    "freya",
    "homepage",
    "mds",
    "search",
    "segugio",
    "spinone",
    "volpino"
  ]
}
