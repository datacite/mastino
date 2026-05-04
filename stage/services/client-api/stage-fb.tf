locals {
  app_name = "client-api-fb"
  fb_dns_name = "api.stage-fb.datacite.org"
}

module "fb-app" {
    source = "../../../modules/ecs-app"

    app_name = local.app_name
    env = "stage"
    vpc_id = var.vpc_id
    task_desired_count = 1
    security_group_id = var.security_group_id
    subnet_datacite-private_id = var.subnet_datacite-private_id
    subnet_datacite-alt_id = var.subnet_datacite-alt_id
    task_cpu = "2028"
    task_memory = "4096"
    container_definition_json = data.template_file.stage-fb-task.rendered
    namespace_id = var.namespace_id
    load_balancer_config = [
      {
        container_port = 80
        target_group_arn = aws_lb_target_group.client-api-stage-fb.arn
      }
    ]
}

data "template_file" "stage-fb-task" {
  template = "${file("client-api.json")}"

  vars = {
      re3data_url                             = var.re3data_url
      bracco_url                              = var.bracco_url
      public_key                              = var.public_key
      jwt_public_key                          = var.jwt_public_key
      jwt_private_key                         = var.jwt_private_key
      session_encrypted_cookie_salt           = var.session_encrypted_cookie_salt
      mysql_user                              = var.mysql_user
      mysql_password                          = var.mysql_password
      mysql_database                          = var.mysql_database
      mysql_host                              = var.mysql_host
      es_name                                 = var.es_name
      es_host                                 = var.es_host
      es_scheme                               = var.es_scheme
      es_port                                 = var.es_port
      es_prefix                               = var.es_prefix
      elastic_password                        = var.elastic_password
      handle_url                              = var.handle_url
      handle_username                         = var.handle_username
      handle_password                         = var.handle_password
      admin_username                          = var.admin_username
      admin_password                          = var.admin_password
      access_key                              = var.api_aws_access_key
      secret_key                              = var.api_aws_secret_key
      region                                  = var.region
      s3_bucket                               = var.s3_bucket
      sentry_dsn                              = var.sentry_dsn
      mailgun_api_key                         = var.mailgun_api_key
      memcache_servers                        = var.memcache_servers
      jwt_blacklisted                         = var.jwt_blacklisted
      slack_webhook_url                       = var.slack_webhook_url
      version                                 = var.lupo_tags["fb_version"]
      sha                                     = ""
      exclude_prefixes_from_data_import       = var.exclude_prefixes_from_data_import
      metadata_storage_bucket_name            = var.metadata_storage_bucket_name
      passenger_max_pool_size                 = var.passenger_max_pool_size
      passenger_min_instances                 = var.passenger_min_instances
      monthly_datafile_bucket                 = var.monthly_datafile_bucket
      monthly_datafile_access_role            = var.monthly_datafile_access_role
      enrichments_ingestion_files_bucket_name = var.enrichments_ingestion_files_bucket_name
      disable_facets_by_default               = var.disable_facets_by_default
      ror_analysis_s3_bucket                  = var.ror_analysis_s3_bucket
  }
}

resource "aws_lb_target_group" "client-api-stage-fb" {
  name        = "client-api-stage-fb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/heartbeat"
    interval = 300
    timeout  = 120
  }
}

resource "aws_lb_listener_rule" "api-graphql-stage-fb" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 48

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client-api-stage-fb.arn
  }

  condition {
    host_header {
      values = [local.fb_dns_name]
    }
  }

  condition {
    path_pattern {
      values = ["/client-api/graphql"]
    }
  }
}

resource "aws_lb_listener_rule" "api-stage-fb" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 54

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client-api-stage-fb.arn
  }

  condition {
    host_header {
      values = [local.fb_dns_name]
    }
  }

}

resource "aws_route53_record" "api-stage-fb" {
  zone_id = data.aws_route53_zone.production.zone_id
  name    = "api.stage-fb.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-api-stage-fb" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "api.stage-fb.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.stage.dns_name]
}

