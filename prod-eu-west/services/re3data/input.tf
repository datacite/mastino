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

data "template_file" "re3data_task" {
  template = file("re3data.json")

  vars = {
    es_host            = var.es_host
    elastic_user       = var.elastic_user
    elastic_password   = var.elastic_password
    access_key         = var.access_key
    secret_key         = var.secret_key
    sentry_dsn         = var.sentry_dsn
    memcache_servers   = var.memcache_servers
    version            = var.schnauzer_tags["version"]
  }
}
