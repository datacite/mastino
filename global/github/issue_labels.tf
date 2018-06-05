# standard labels for GitHub issues across all repositories
# based on https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues/
# categories
resource "github_issue_label" "create" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "create"
  color      = "b1c9f0"
}

resource "github_issue_label" "find" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "find"
  color      = "b1c9f0"
}

resource "github_issue_label" "use" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "use"
  color      = "b1c9f0"
}

resource "github_issue_label" "track" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "track"
  color      = "b1c9f0"
}

resource "github_issue_label" "connect" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "connect"
  color      = "b1c9f0"
}

resource "github_issue_label" "support" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "support"
  color      = "b1c9f0"
}

resource "github_issue_label" "advocate" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "advocate"
  color      = "b1c9f0"
}

# stakeholders
resource "github_issue_label" "member" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "member"
  color      = "f9cfb9"
}

resource "github_issue_label" "data_center" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "data center"
  color      = "f9cfb9"
}

resource "github_issue_label" "researcher" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "researcher"
  color      = "f9cfb9"
}

resource "github_issue_label" "library" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "library"
  color      = "f9cfb9"
}

resource "github_issue_label" "national_library" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "national library"
  color      = "f9cfb9"
}

resource "github_issue_label" "publisher" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "publisher"
  color      = "f9cfb9"
}

resource "github_issue_label" "funder" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "funder"
  color      = "f9cfb9"
}

# waffle board column (backlog and done not needed)
resource "github_issue_label" "discussion" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "discussion"
  color      = "ededed"
}

resource "github_issue_label" "planning" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "planning"
  color      = "ededed"
}

resource "github_issue_label" "ready" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "ready"
  color      = "ededed"
}

resource "github_issue_label" "in_progress" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "in progress"
  color      = "ededed"
}

resource "github_issue_label" "needs_review" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "needs review"
  color      = "ededed"
}

# product development
resource "github_issue_label" "feature_definition" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "feature definition"
  color      = "ffc000"
}

resource "github_issue_label" "design_requirements" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "design requirements"
  color      = "ffc000"
}

resource "github_issue_label" "development" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "development"
  color      = "ffc000"
}

resource "github_issue_label" "documentation" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "documentation"
  color      = "ffc000"
}

resource "github_issue_label" "launch" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "launch"
  color      = "ffc000"
}

# problems
resource "github_issue_label" "bug" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "bug"
  color      = "ee0701"
}

resource "github_issue_label" "refactor" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "refactor"
  color      = "ee0701"
}

resource "github_issue_label" "redesign" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "redesign"
  color      = "ee0701"
}

resource "github_issue_label" "security" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "security"
  color      = "ee0701"
}

# improvements
resource "github_issue_label" "enhancement" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "enhancement"
  color      = "4aadff"
}

resource "github_issue_label" "optimization" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "optimization"
  color      = "4aadff"
}

# additions
resource "github_issue_label" "feature" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "feature"
  color      = "7fc53c"
}

# inactive
resource "github_issue_label" "wontfix" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "wontfix"
  color      = "c8d1da"
}

resource "github_issue_label" "duplicate" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "duplicate"
  color      = "c8d1da"
}

resource "github_issue_label" "invalid" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "invalid"
  color      = "c8d1da"
}

# user story
resource "github_issue_label" "user_story" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "user story"
  color      = "d4c5f9"
}

# feedback
resource "github_issue_label" "question" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "question"
  color      = "c11169"
}

# experience
resource "github_issue_label" "ux" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "ux"
  color      = "ffb353"
}

resource "github_issue_label" "design" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "design"
  color      = "ffb353"
}

resource "github_issue_label" "copy" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "copy"
  color      = "ffb353"
}

# mindless
resource "github_issue_label" "chore" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "chore"
  color      = "fef1b0"
}

resource "github_issue_label" "legal" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "legal"
  color      = "fef1b0"
}

# projects
resource "github_issue_label" "membership" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "Membership"
  color      = "006b75"
}

resource "github_issue_label" "mdc" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "Make Data Count"
  color      = "006b75"
}

resource "github_issue_label" "freya" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "FREYA"
  color      = "006b75"
}

resource "github_issue_label" "fabrica" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "DOI Fabrica"
  color      = "006b75"
}

resource "github_issue_label" "re3data" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "re3data"
  color      = "006b75"
}

resource "github_issue_label" "data science" {
  count = "${length(var.github_repositories)}"
  repository = "${var.github_repositories[count.index]}"
  name       = "data science"
  color      = "ffc000"
}