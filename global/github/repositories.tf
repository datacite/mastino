resource "github_repository" "blog" {
  name         = "blog"
  description  = "The DataCite blog"
  homepage_url = "https://blog.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "bolognese" {
  name         = "bolognese"
  description  = "Ruby gem and command-line utility for conversion of DOI metadata"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "bracco" {
  name         = "bracco"
  description  = "Frontend for the DataCite DOI Fabrica service"
  homepage_url = "https://doi.datacite.org"
  has_wiki     = false
  has_issues   = true
  has_downloads = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "cheetoh" {
  name         = "cheetoh"
  description  = "The DataCite EZID compatibility API"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "datacite" {
  name         = "datacite"
  description  = "Issues and milestones for the DataCite organization"
  homepage_url = "https://www.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "freya" {
  name         = "freya"
  description  = "Issues and milestones for the FREYA project"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "homepage" {
  name         = "homepage"
  description  = "The DataCite homepage"
  homepage_url = "https://www.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "http-redirect" {
  name         = "http-redirect"
  description  = "Nginx reverse-proxy that redirects all http requests to https"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "lupo" {
  name         = "lupo"
  description  = "DataCite Client API"
  homepage_url = "https://api.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "levriero" {
  name         = "levriero"
  description  = "DataCite Elasticsearch API"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "maremma" {
  name         = "maremma"
  description  = "Ruby utility library for network calls"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "mastino" {
  name         = "mastino"
  description  = "Configuration of DataCite infrastructure"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "mds" {
  name         = "mds"
  description  = "The DataCite Metadata Store (MDS)"
  homepage_url = "https://mds.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "oaip" {
  name         = "oaip"
  description  = "The DataCite OAI-PMH Data Provider"
  homepage_url = "https://oai.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "omniauth-orcid" {
  name         = "omniauth-orcid"
  description  = "ORCID Strategy for OmniAuth"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "schema" {
  name         = "schema"
  description  = "DataCite Metadata Schema Repository"
  homepage_url = "https://schema.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "search" {
  name         = "search"
  description  = "The DataCite search backend"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "segugio" {
  name         = "segugio"
  description  = "The DataCite assets server"
  homepage_url = "https://assets.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "spinone" {
  name         = "spinone"
  description  = "The DataCite REST API"
  homepage_url = "https://api.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "stats-portal" {
  name         = "stats-portal"
  description  = "Static website for DataCite summary statistics"
  homepage_url = "https://stats.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "volpino" {
  name         = "volpino"
  description  = "The DataCite Profiles service"
  homepage_url = "https://profiles.datacite.org"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "dackel" {
  name         = "dackel"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "schnauzer" {
  name         = "schnauzer"
  has_wiki     = false
  has_issues   = true

  lifecycle {
    prevent_destroy = true
  }
}
