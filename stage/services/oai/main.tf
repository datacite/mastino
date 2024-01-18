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

data "aws_lb" "this" {
  name = var.lb_name
}

locals {
  app_name = "oai"
  env = "stage"
  service_name = "${local.app_name}-${local.env}"
  awslogs_group = "/ecs/${local.service_name}"

  oai_container_definition = jsonencode(
    [{
      "name": local.service_name
      "image": "datacite/viringo",
      "cpu": 512,
      "memory": 1024,
      "networkMode": "awsvpc",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group" : local.awslogs_group,
          "awslogs-region": "eu-west-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "environment" : [
        {
          "name" : "PUBLIC_KEY",
          "value" : var.public_key
        },
        {
          "name" : "DATACITE_API_URL",
          "value" : var.api_url
        },
        {
          "name" : "DATACITE_API_ADMIN_PASSWORD",
          "value" : var.api_password
        },
        {
          "name" : "LOG_LEVEL",
          "value" : "INFO"
        },
        {
          "name": "OAIPMH_BASE_URL",
          "value": var.base_url
        },
        {
          "name" : "SENTRY_DSN",
          "value" : var.sentry_dsn
        },
        {
          "name" : "GITHUB_VERSION",
          "value" : var.viringo_tags["sha"]
        }
      ]
    }]
  )
}

module "ecs-service" {
  source = "github.com/datacite/terraform-aws-ecs-service"

  app_name = local.app_name
  env = local.env
  lb_name = var.lb_name
  vpc_id = var.vpc_id
  subnet_ids = [
    var.subnet_datacite-private_id,
    var.subnet_datacite-alt_id
  ]
  security_group_ids = [
    var.security_group_id
  ]
  namespace_id = var.namespace_id

  desired_container_count = 1
  use_fargate = true
  fargate_cpu = 512
  fargate_memory = 1024

  container_definitions = local.oai_container_definition

  setup_alb = true
  dns_record_name = "oai.stage.datacite.org"
}

resource "aws_route53_record" "oai-stage" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "oai.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.this.dns_name]
}