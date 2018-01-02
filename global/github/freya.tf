data "github_team" "freya" {
  slug = "freya"
}

resource "github_team_membership" "freya_membership_mfenner" {
  team_id  = "${data.github_team.freya.id}"
  username = "mfenner"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_kjgarza" {
  team_id  = "${data.github_team.freya.id}"
  username = "kjgarza"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_pcruse" {
  team_id  = "${data.github_team.freya.id}"
  username = "pcruse"
  role     = "maintainer"
}

resource "github_team_membership" "freya_membership_brittadreyer" {
  team_id  = "${data.github_team.freya.id}"
  username = "brittadreyer"
  role     = "member"
}

resource "github_team_membership" "freya_membership_richardhallett" {
  team_id  = "${data.github_team.freya.id}"
  username = "richardhallett"
  role     = "maintainer"
}
