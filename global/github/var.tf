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
    "homepage",
    "http-redirect",
    "lupo",
    "levriero",
    "maremma",
    "mastino",
    "mds",
    "oaip",
    "omniauth-orcid",
    "schema",
    "search",
    "segugio",
    "spinone",
    "stats-portal",
    "volpino",
    "dackel",
    "schnauzer",
    "poodle",
    "lagottino"
  ]
}
