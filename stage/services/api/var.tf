variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {}

variable "spinone_tags" {
  type = "map"
}

variable "lb_name" {
  default = "lb-stage"
}

variable "security_group_id" {}

variable "ttl" {
  default = "300"
}

variable "subnet_datacite-private_id" {}
variable "subnet_datacite-alt_id" {}

variable "solr_url" {
  default = "https://solr.test.datacite.org/api"
}
variable "volpino_url" {
  default = "https://profiles.test.datacite.org/api"
}
variable "orcid_update_url" {
  default = "https://profiles.test.datacite.org"
}
variable "api_url" {
  default = "https://app.test.datacite.org"
}
variable "blog_url" {
  default = "https://blog.test.datacite.org"
}

variable "memcache_servers" {
  default = "memcached.test.datacite.org:11211"
}

variable "volpino_token" {}
variable "jwt_public_key" {}
variable "orcid_update_uuid" {}
variable "orcid_update_token" {}
variable "github_personal_access_token" {}
variable "bugsnag_key" {}
variable "mailgun_api_key" {}

variable "github_milestones_url" {
  default = "https://api.github.com/repos/datacite/datacite"
}
variable "github_issues_repo_url" {
  default = "https://github.com/datacite/datacite"
}
