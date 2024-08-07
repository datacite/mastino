provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
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

data "aws_ecs_cluster" "test" {
  cluster_name = "test"
}

data "aws_iam_role" "ecs_service" {
  name = "ecs_service"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_lb" "test" {
  name = var.lb_name
}

data "aws_lb_listener" "test" {
  load_balancer_arn = data.aws_lb.test.arn
  port = 443
}

data "template_file" "federation_task" {
  template = file("federation.json")

  vars = {
    sentry_dsn         = var.sentry_dsn
    profiles_url       = var.profiles_url
    client_api_url     = var.client_api_url
    api_url            = var.api_url
    strapi_url         = var.strapi_url
    apollo_api_key     = var.apollo_api_key
    version            = var.vaestgoetaspets_tags["version"]
  }
}
