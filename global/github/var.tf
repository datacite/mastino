variable "github_token" {}
variable "github_organization" {}
variable "github_repositories" {
  type    = "list"

  default = [
    "blog",
    "bolognese",
    "bracco",
    "cheetoh",
    "datacite",
    "freya",
    "homepage",
    "http-redirect",
    "lupo",
    "levriero",
    "maremma",
    "oaip",
    "omniauth-orcid",
    "mds",
    "schema",
    "search",
    "segugio",
    "spinone",
    "stats-portal",
    "volpino"
  ]
}
