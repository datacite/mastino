resource "github_team" "freya" {
  name        = "freya"
  description = "The Freya Team"
  privacy     = "secret"
}

resource "github_team_membership" "freya_membership_mfenner" {
  team_id  = "${github_team.freya.id}"
  username = "mfenner"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_kjgarza" {
  team_id  = "${github_team.freya.id}"
  username = "kjgarza"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_pcruse" {
  team_id  = "${github_team.freya.id}"
  username = "pcruse"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_brittadreyer" {
  team_id  = "${github_team.freya.id}"
  username = "brittadreyer"
  role     = "member"
}

resource "github_team_membership" "freya_membership_richardhallett" {
  team_id  = "${github_team.freya.id}"
  username = "richardhallett"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_hcousijn" {
  team_id  = "${github_team.freya.id}"
  username = "hcousijn"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_daslerr" {
  team_id  = "${github_team.freya.id}"
  username = "daslerr"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_ChrisVFerg" {
  team_id  = "${github_team.freya.id}"
  username = "ChrisVFerg"
  role     = "member"
}

resource "github_team_membership" "freya_membership_ioannistsanaktsidis" {
  team_id  = "${github_team.freya.id}"
  username = "ioannistsanaktsidis"
  role     = "member"
}

resource "github_team_membership" "freya_membership_markusstocker" {
  team_id  = "${github_team.freya.id}"
  username = "markusstocker"
  role     = "member"
}

resource "github_team_membership" "freya_membership_mbdebian" {
  team_id  = "${github_team.freya.id}"
  username = "mbdebian"
  role     = "member"
}

resource "github_team_membership" "freya_membership_RachaelKotarski" {
  team_id  = "${github_team.freya.id}"
  username = "RachaelKotarski"
  role     = "member"
}

resource "github_team_membership" "freya_membership_sarala" {
  team_id  = "${github_team.freya.id}"
  username = "sarala"
  role     = "member"
}

resource "github_team_membership" "freya_membership_vasilyb" {
  team_id  = "${github_team.freya.id}"
  username = "vasilyb"
  role     = "member"
}

resource "github_team_membership" "freya_membership_wilkos-dans" {
  team_id  = "${github_team.freya.id}"
  username = "wilkos-dans"
  role     = "member"
}

# standard labels for GitHub issues across all repositories
# based on https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues/
# FREYA partners
resource "github_issue_label" "STFC" {
  repository = "${github_repository.freya}"
  name       = "STFC"
  color      = "b1c9f0"
}

resource "github_issue_label" "CERN" {
  repository = "${github_repository.freya}"
  name       = "CERN"
  color      = "b1c9f0"
}

resource "github_issue_label" "EMBL-EBI" {
  repository = "${github_repository.freya}"
  name       = "EMBL-EBI"
  color      = "b1c9f0"
}

resource "github_issue_label" "DANS" {
  repository = "${github_repository.freya}"
  name       = "DANS"
  color      = "b1c9f0"
}

resource "github_issue_label" "Pangaea" {
  repository = "${github_repository.freya}"
  name       = "Pangaea"
  color      = "b1c9f0"
}

resource "github_issue_label" "DataCite" {
  repository = "${github_repository.freya}"
  name       = "DataCite"
  color      = "b1c9f0"
}

resource "github_issue_label" "ORCID" {
  repository = "${github_repository.freya}"
  name       = "ORCID"
  color      = "b1c9f0"
}

resource "github_issue_label" "Hindawi" {
  repository = "${github_repository.freya}"
  name       = "Hindawi"
  color      = "b1c9f0"
}

resource "github_issue_label" "PLOS" {
  repository = "${github_repository.freya}"
  name       = "PLOS"
  color      = "b1c9f0"
}

resource "github_issue_label" "Crossref" {
  repository = "${github_repository.freya}"
  name       = "Crossref"
  color      = "b1c9f0"
}

resource "github_issue_label" "British Library" {
  repository = "${github_repository.freya}"
  name       = "British Library"
  color      = "b1c9f0"
}

# stakeholders
resource "github_issue_label" "data_center" {
  repository = "${github_repository.freya}"
  name       = "data center"
  color      = "f9cfb9"
}

resource "github_issue_label" "researcher" {
  repository = "${github_repository.freya}"
  name       = "researcher"
  color      = "f9cfb9"
}

resource "github_issue_label" "library" {
  repository = "${github_repository.freya}"
  name       = "library"
  color      = "f9cfb9"
}

resource "github_issue_label" "national_library" {
  repository = "${github_repository.freya}"
  name       = "national library"
  color      = "f9cfb9"
}

resource "github_issue_label" "publisher" {
  repository = "${github_repository.freya}"
  name       = "publisher"
  color      = "f9cfb9"
}

resource "github_issue_label" "funder" {
  repository = "${github_repository.freya}"
  name       = "funder"
  color      = "f9cfb9"
}

# waffle board column (backlog and done not needed)
resource "github_issue_label" "discussion" {
  repository = "${github_repository.freya}"
  name       = "discussion"
  color      = "ededed"
}

resource "github_issue_label" "planning" {
  repository = "${github_repository.freya}"
  name       = "planning"
  color      = "ededed"
}

resource "github_issue_label" "ready" {
  repository = "${github_repository.freya}"
  name       = "ready"
  color      = "ededed"
}

resource "github_issue_label" "in_progress" {
  repository = "${github_repository.freya}"
  name       = "in progress"
  color      = "ededed"
}

resource "github_issue_label" "needs_review" {
  repository = "${github_repository.freya}"
  name       = "needs review"
  color      = "ededed"
}

# product development
resource "github_issue_label" "feature_definition" {
  repository = "${github_repository.freya}"
  name       = "feature definition"
  color      = "ffc000"
}

resource "github_issue_label" "design_requirements" {
  repository = "${github_repository.freya}"
  name       = "design requirements"
  color      = "ffc000"
}

resource "github_issue_label" "development" {
  repository = "${github_repository.freya}"
  name       = "development"
  color      = "ffc000"
}

resource "github_issue_label" "documentation" {
  repository = "${github_repository.freya}"
  name       = "documentation"
  color      = "ffc000"
}

resource "github_issue_label" "launch" {
  repository = "${github_repository.freya}"
  name       = "launch"
  color      = "ffc000"
}

resource "github_issue_label" "data_science" {
  repository = "${github_repository.freya}"
  name       = "data science"
  color      = "ffc000"
}

# problems
resource "github_issue_label" "bug" {
  repository = "${github_repository.freya}"
  name       = "bug"
  color      = "ee0701"
}

resource "github_issue_label" "refactor" {
  repository = "${github_repository.freya}"
  name       = "refactor"
  color      = "ee0701"
}

resource "github_issue_label" "redesign" {
  repository = "${github_repository.freya}"
  name       = "redesign"
  color      = "ee0701"
}

resource "github_issue_label" "security" {
  repository = "${github_repository.freya}"
  name       = "security"
  color      = "ee0701"
}

# improvements
resource "github_issue_label" "enhancement" {
  repository = "${github_repository.freya}"
  name       = "enhancement"
  color      = "4aadff"
}

resource "github_issue_label" "optimization" {
  repository = "${github_repository.freya}"
  name       = "optimization"
  color      = "4aadff"
}

# additions
resource "github_issue_label" "feature" {
  repository = "${github_repository.freya}"
  name       = "feature"
  color      = "7fc53c"
}

# inactive
resource "github_issue_label" "wontfix" {
  repository = "${github_repository.freya}"
  name       = "wontfix"
  color      = "c8d1da"
}

resource "github_issue_label" "duplicate" {
  repository = "${github_repository.freya}"
  name       = "duplicate"
  color      = "c8d1da"
}

resource "github_issue_label" "invalid" {
  repository = "${github_repository.freya}"
  name       = "invalid"
  color      = "c8d1da"
}

# user story
resource "github_issue_label" "user_story" {
  repository = "${github_repository.freya}"
  name       = "user story"
  color      = "d4c5f9"
}

# feedback
resource "github_issue_label" "question" {
  repository = "${github_repository.freya}"
  name       = "question"
  color      = "c11169"
}

# experience
resource "github_issue_label" "ux" {
  repository = "${github_repository.freya}"
  name       = "ux"
  color      = "ffb353"
}

resource "github_issue_label" "design" {
  repository = "${github_repository.freya}"
  name       = "design"
  color      = "ffb353"
}

resource "github_issue_label" "copy" {
  repository = "${github_repository.freya}"
  name       = "copy"
  color      = "ffb353"
}

# mindless
resource "github_issue_label" "housekeeping" {
  repository = "${github_repository.freya}"
  name       = "housekeeping"
  color      = "fef1b0"
}

resource "github_issue_label" "legal" {
  repository = "${github_repository.freya}"
  name       = "legal"
  color      = "fef1b0"
}

# work packages
rresource "github_issue_label" "wp1" {
  repository = "${github_repository.freya}"
  name       = "WP1"
  color      = "006b75"
}

resource "github_issue_label" "wp2" {
  repository = "${github_repository.freya}"
  name       = "WP2"
  color      = "006b75"
}

resource "github_issue_label" "wp3" {
  repository = "${github_repository.freya}"
  name       = "WP3"
  color      = "006b75"
}

resource "github_issue_label" "wp4" {
  repository = "${github_repository.freya}"
  name       = "WP4"
  color      = "006b75"
}

resource "github_issue_label" "wp5" {
  repository = "${github_repository.freya}"
  name       = "WP5"
  color      = "006b75"
}

resource "github_issue_label" "wp6" {
  repository = "${github_repository.freya}"
  name       = "WP6"
  color      = "006b75"
}