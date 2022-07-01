provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version    = "~> 2.70"
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name = "datacite.org"
  private_zone = true
}

data "aws_security_group" "datacite-private" {
  id = var.security_group_id
}

data "aws_subnet" "datacite-private" {
  id = var.subnet_datacite-private_id
}

data "aws_subnet" "datacite-alt" {
  id = var.subnet_datacite-alt_id
}

data "aws_ecs_cluster" "default" {
  cluster_name = "default"
}

data "aws_iam_role" "ecs_service" {
  name = "ecs_service"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_lb" "default" {
  name = var.lb_name
}

data "aws_lb_listener" "default" {
  load_balancer_arn = data.aws_lb.default.arn
  port = 443
}


data "template_file" "levriero_task" {
  template = file("levriero.json")

  vars = {
    public_key         = var.public_key
    jwt_public_key     = var.jwt_public_key
    jwt_private_key    = var.jwt_private_key
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    sentry_dsn         = var.sentry_dsn
    memcache_servers   = var.memcache_servers
    slack_webhook_url  = var.slack_webhook_url
    volpino_url        = var.volpino_url
    crossref_query_url = var.crossref_query_url
    staff_admin_token = var.staff_admin_token
    staff_profiles_admin_token  = var.staff_profiles_admin_token
    eventdata_url      = var.eventdata_url
    eventdata_token    = var.eventdata_token
    api_url            = var.api_url
    lagottino_url      = var.lagottino_url
    datacite_crossref_source_token = var.datacite_crossref_source_token
    datacite_related_source_token  = var.datacite_related_source_token
    datacite_other_source_token    = var.datacite_other_source_token
    datacite_url_source_token      = var.datacite_url_source_token
    datacite_arxiv_source_token    = var.datacite_arxiv_source_token
    datacite_pmid_source_token    = var.datacite_pmid_source_token
    datacite_igsn_source_token    = var.datacite_igsn_source_token
    datacite_handle_source_token    = var.datacite_handle_source_token
    datacite_funder_source_token   = var.datacite_funder_source_token
    datacite_affiliation_source_token  = var.datacite_affiliation_source_token
    orcid_affiliation_source_token  = var.orcid_affiliation_source_token
    datacite_resolution_source_token   = var.datacite_resolution_source_token
    datacite_usage_source_token    = var.datacite_usage_source_token
    datacite_orcid_auto_update_source_token = var.datacite_orcid_auto_update_source_token
    crossref_orcid_auto_update_source_token = var.crossref_orcid_auto_update_source_token
    crossref_related_source_token = var.crossref_related_source_token
    crossref_funder_source_token = var.crossref_funder_source_token
    crossref_datacite_source_token = var.crossref_datacite_source_token
    crossref_other_source_token = var.crossref_other_source_token
    version            = var.levriero_tags["version"]
  }
}
