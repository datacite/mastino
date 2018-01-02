resource "github_repository" "blog" {
  name         = "blog"
  description  = "The DataCite blog"
  homepage_url = "https://blog.datacite.org"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "bolognese" {
  name         = "bolognese"
  description  = "Ruby gem and command-line utility for conversion of DOI metadata"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "cheetoh" {
  name         = "cheetoh"
  description  = "The DataCite EZID compatibility API"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "datacite" {
  name         = "datacite"
  description  = "Issues and milestones for the DataCite organization"
  homepage_url = "https://www.datacite.org"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "freya" {
  name         = "freya"
  description  = "Issues and milestones for the FREYA project"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "homepage" {
  name         = "homepage"
  description  = "The DataCite homepage"
  homepage_url = "https://www.datacite.org"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "mds" {
  name         = "mds"
  description  = "The DataCite Metadata Store (MDS)"
  homepage_url = "https://mds.datacite.org"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "search" {
  name         = "search"
  description  = "The DataCite search backend"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "segugio" {
  name         = "segugio"
  description  = "The DataCite assets server"
  homepage_url = "https://assets.datacite.org"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "spinone" {
  name         = "spinone"
  description  = "The DataCite REST API"
  homepage_url = "https://api.datacite.org"
  has_wiki     = false
  has_issues   = true
}

resource "github_repository" "volpino" {
  name         = "volpino"
  description  = "The DataCite Profiles service"
  homepage_url = "https://profiles.datacite.org"
  has_wiki     = false
  has_issues   = true
}
