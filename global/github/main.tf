provider "github" {
  version      = "~> 0.1.1"
  token        = "${var.github_token}"
  organization = "${var.github_organization}"
}
