resource "github_team" "freya" {
  name        = "freya"
  description = "The Freya Team"
  privacy     = "secret"
}

// resource "github_team_membership" "freya_membership_mfenner" {
//   team_id  = "${github_team.freya.id}"
//   username = "mfenner"
//   role     = "maintainer"
// }

// resource "github_team_membership" "freya_membership_kjgarza" {
//   team_id  = "${github_team.freya.id}"
//   username = "kjgarza"
//   role     = "maintainer"
// }

// resource "github_team_membership" "freya_membership_pcruse" {
//   team_id  = "${github_team.freya.id}"
//   username = "pcruse"
//   role     = "maintainer"
// }

// resource "github_team_membership" "freya_membership_brittadreyer" {
//   team_id  = "${github_team.freya.id}"
//   username = "brittadreyer"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_richardhallett" {
//   team_id  = "${github_team.freya.id}"
//   username = "richardhallett"
//   role     = "maintainer"
// }

// resource "github_team_membership" "freya_membership_hcousijn" {
//   team_id  = "${github_team.freya.id}"
//   username = "hcousijn"
//   role     = "maintainer"
// }

// resource "github_team_membership" "freya_membership_daslerr" {
//   team_id  = "${github_team.freya.id}"
//   username = "daslerr"
//   role     = "maintainer"
// }

// resource "github_team_membership" "freya_membership_ChrisVFerg" {
//   team_id  = "${github_team.freya.id}"
//   username = "ChrisVFerg"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_ioannistsanaktsidis" {
//   team_id  = "${github_team.freya.id}"
//   username = "ioannistsanaktsidis"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_markusstocker" {
//   team_id  = "${github_team.freya.id}"
//   username = "markusstocker"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_mbdebian" {
//   team_id  = "${github_team.freya.id}"
//   username = "mbdebian"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_RachaelKotarski" {
//   team_id  = "${github_team.freya.id}"
//   username = "RachaelKotarski"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_sarala" {
//   team_id  = "${github_team.freya.id}"
//   username = "sarala"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_vasilyb" {
//   team_id  = "${github_team.freya.id}"
//   username = "vasilyb"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_wilkos-dans" {
//   team_id  = "${github_team.freya.id}"
//   username = "wilkos-dans"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_Ruecue" {
//   team_id  = "${github_team.freya.id}"
//   username = "Ruecue"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_ArtemisLav" {
//   team_id  = "${github_team.freya.id}"
//   username = "ArtemisLav"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_Uschindler" {
//   team_id  = "${github_team.freya.id}"
//   username = "Uschindler"
//   role     = "member"
// }

// resource "github_team_membership" "freya_membership_Suenjedt" {
//   team_id  = "${github_team.freya.id}"
//   username = "Suenjedt"
//   role     = "member"
// }

# standard labels for GitHub issues across all repositories
# based on https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues/
# FREYA partners
resource "github_issue_label" "STFC" {
  repository = "${github_repository.freya.name}"
  name       = "STFC"
  color      = "b1c9f0"
}

resource "github_issue_label" "CERN" {
  repository = "${github_repository.freya.name}"
  name       = "CERN"
  color      = "b1c9f0"
}

resource "github_issue_label" "EMBL-EBI" {
  repository = "${github_repository.freya.name}"
  name       = "EMBL-EBI"
  color      = "b1c9f0"
}

resource "github_issue_label" "DANS" {
  repository = "${github_repository.freya.name}"
  name       = "DANS"
  color      = "b1c9f0"
}

resource "github_issue_label" "Pangaea" {
  repository = "${github_repository.freya.name}"
  name       = "PANGAEA"
  color      = "b1c9f0"
}

resource "github_issue_label" "DataCite" {
  repository = "${github_repository.freya.name}"
  name       = "DataCite"
  color      = "b1c9f0"
}

resource "github_issue_label" "ARDC" {
  repository = "${github_repository.freya.name}"
  name       = "ARDC"
  color      = "b1c9f0"
}

resource "github_issue_label" "ORCID" {
  repository = "${github_repository.freya.name}"
  name       = "ORCID"
  color      = "b1c9f0"
}

resource "github_issue_label" "Hindawi" {
  repository = "${github_repository.freya.name}"
  name       = "Hindawi"
  color      = "b1c9f0"
}

resource "github_issue_label" "PLOS" {
  repository = "${github_repository.freya.name}"
  name       = "PLOS"
  color      = "b1c9f0"
}

resource "github_issue_label" "Crossref" {
  repository = "${github_repository.freya.name}"
  name       = "Crossref"
  color      = "b1c9f0"
}

resource "github_issue_label" "British_Library" {
  repository = "${github_repository.freya.name}"
  name       = "British Library"
  color      = "b1c9f0"
}

# stakeholders
resource "github_issue_label" "freya_data_center" {
  repository = "${github_repository.freya.name}"
  name       = "data center"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_researcher" {
  repository = "${github_repository.freya.name}"
  name       = "researcher"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_bibliometrician" {
  repository = "${github_repository.freya.name}"
  name       = "bibliometrician"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_library" {
  repository = "${github_repository.freya.name}"
  name       = "library"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_national_library" {
  repository = "${github_repository.freya.name}"
  name       = "national library"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_publisher" {
  repository = "${github_repository.freya.name}"
  name       = "publisher"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_service_provider" {
  repository = "${github_repository.freya.name}"
  name       = "service_provider"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_facility" {
  repository = "${github_repository.freya.name}"
  name       = "facility"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_institution" {
  repository = "${github_repository.freya.name}"
  name       = "institution"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_curator" {
  repository = "${github_repository.freya.name}"
  name       = "curator"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_software_author" {
  repository = "${github_repository.freya.name}"
  name       = "software author"
  color      = "f9cfb9"
}

resource "github_issue_label" "freya_funder" {
  repository = "${github_repository.freya.name}"
  name       = "funder"
  color      = "f9cfb9"
}

# waffle board column (backlog and done not needed)
resource "github_issue_label" "freya_next" {
  repository = "${github_repository.freya.name}"
  name       = "next"
  color      = "ededed"
}

resource "github_issue_label" "freya_in_progress" {
  repository = "${github_repository.freya.name}"
  name       = "in progress"
  color      = "ededed"
}

resource "github_issue_label" "freya_review" {
  repository = "${github_repository.freya.name}"
  name       = "review"
  color      = "ededed"
}

# product development
resource "github_issue_label" "freya_feature_definition" {
  repository = "${github_repository.freya.name}"
  name       = "feature definition"
  color      = "ffc000"
}

resource "github_issue_label" "freya_design_requirements" {
  repository = "${github_repository.freya.name}"
  name       = "design requirements"
  color      = "ffc000"
}

resource "github_issue_label" "freya_development" {
  repository = "${github_repository.freya.name}"
  name       = "development"
  color      = "ffc000"
}

resource "github_issue_label" "freya_documentation" {
  repository = "${github_repository.freya.name}"
  name       = "documentation"
  color      = "ffc000"
}

resource "github_issue_label" "freya_launch" {
  repository = "${github_repository.freya.name}"
  name       = "launch"
  color      = "ffc000"
}

resource "github_issue_label" "freya_data_science" {
  repository = "${github_repository.freya.name}"
  name       = "data science"
  color      = "ffc000"
}

# problems
resource "github_issue_label" "freya_bug" {
  repository = "${github_repository.freya.name}"
  name       = "bug"
  color      = "ee0701"
}

resource "github_issue_label" "freya_refactor" {
  repository = "${github_repository.freya.name}"
  name       = "refactor"
  color      = "ee0701"
}

resource "github_issue_label" "freya_redesign" {
  repository = "${github_repository.freya.name}"
  name       = "redesign"
  color      = "ee0701"
}

resource "github_issue_label" "freya_security" {
  repository = "${github_repository.freya.name}"
  name       = "security"
  color      = "ee0701"
}

# PID types
resource "github_issue_label" "freya_data" {
  repository = "${github_repository.freya.name}"
  name       = "data"
  color      = "4aadff"
}

resource "github_issue_label" "freya_software" {
  repository = "${github_repository.freya.name}"
  name       = "software"
  color      = "4aadff"
}

resource "github_issue_label" "freya_organization" {
  repository = "${github_repository.freya.name}"
  name       = "organization"
  color      = "4aadff"
}

resource "github_issue_label" "freya_person" {
  repository = "${github_repository.freya.name}"
  name       = "person"
  color      = "4aadff"
}

resource "github_issue_label" "freya_repository" {
  repository = "${github_repository.freya.name}"
  name       = "repository"
  color      = "4aadff"
}

resource "github_issue_label" "freya_sample" {
  repository = "${github_repository.freya.name}"
  name       = "sample"
  color      = "4aadff"
}

resource "github_issue_label" "freya_conference" {
  repository = "${github_repository.freya.name}"
  name       = "conference"
  color      = "4aadff"
}

resource "github_issue_label" "freya_instrument" {
  repository = "${github_repository.freya.name}"
  name       = "instrument"
  color      = "4aadff"
}

resource "github_issue_label" "freya_grant" {
  repository = "${github_repository.freya.name}"
  name       = "grant"
  color      = "4aadff"
}

resource "github_issue_label" "freya_project" {
  repository = "${github_repository.freya.name}"
  name       = "project"
  color      = "4aadff"
}

resource "github_issue_label" "freya_article" {
  repository = "${github_repository.freya.name}"
  name       = "article"
  color      = "4aadff"
}

# additions
resource "github_issue_label" "freya_feature" {
  repository = "${github_repository.freya.name}"
  name       = "feature"
  color      = "7fc53c"
}

# inactive
resource "github_issue_label" "freya_wontfix" {
  repository = "${github_repository.freya.name}"
  name       = "wontfix"
  color      = "c8d1da"
}

resource "github_issue_label" "freya_duplicate" {
  repository = "${github_repository.freya.name}"
  name       = "duplicate"
  color      = "c8d1da"
}

resource "github_issue_label" "freya_invalid" {
  repository = "${github_repository.freya.name}"
  name       = "invalid"
  color      = "c8d1da"
}

# user story
resource "github_issue_label" "freya_user_story" {
  repository = "${github_repository.freya.name}"
  name       = "user story"
  color      = "d4c5f9"
}

# feedback
resource "github_issue_label" "freya_question" {
  repository = "${github_repository.freya.name}"
  name       = "question"
  color      = "c11169"
}

# experience
resource "github_issue_label" "freya_ux" {
  repository = "${github_repository.freya.name}"
  name       = "ux"
  color      = "ffb353"
}

resource "github_issue_label" "freya_design" {
  repository = "${github_repository.freya.name}"
  name       = "design"
  color      = "ffb353"
}

resource "github_issue_label" "freya_copy" {
  repository = "${github_repository.freya.name}"
  name       = "copy"
  color      = "ffb353"
}

# mindless
resource "github_issue_label" "freya_housekeeping" {
  repository = "${github_repository.freya.name}"
  name       = "housekeeping"
  color      = "fef1b0"
}

resource "github_issue_label" "freya_legal" {
  repository = "${github_repository.freya.name}"
  name       = "legal"
  color      = "fef1b0"
}

# work packages
resource "github_issue_label" "wp1" {
  repository = "${github_repository.freya.name}"
  name       = "WP1"
  color      = "006b75"
}

resource "github_issue_label" "wp2" {
  repository = "${github_repository.freya.name}"
  name       = "WP2"
  color      = "006b75"
}

resource "github_issue_label" "wp3" {
  repository = "${github_repository.freya.name}"
  name       = "WP3"
  color      = "006b75"
}

resource "github_issue_label" "wp4" {
  repository = "${github_repository.freya.name}"
  name       = "WP4"
  color      = "006b75"
}

resource "github_issue_label" "wp5" {
  repository = "${github_repository.freya.name}"
  name       = "WP5"
  color      = "006b75"
}

resource "github_issue_label" "wp6" {
  repository = "${github_repository.freya.name}"
  name       = "WP6"
  color      = "006b75"
}

resource "github_issue_label" "freya_pid_graph" {
  repository = "${github_repository.freya.name}"
  name       = "PID Graph"
  color      = "006b75"
}

resource "github_issue_label" "freya_pid_forum" {
  repository = "${github_repository.freya.name}"
  name       = "PID Forum"
  color      = "006b75"
}

resource "github_issue_label" "freya_pid_commons" {
  repository = "${github_repository.freya.name}"
  name       = "PID Commons"
  color      = "006b75"
}