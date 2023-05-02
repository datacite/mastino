resource "aws_ecs_service" "search-stage" {
  name = "search-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.search-stage.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.search-stage.id
    container_name   = "search-stage"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.stage"
  ]
}

resource "aws_lb_target_group" "search-stage" {
  name     = "search-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  stickiness {
    type   = "lb_cookie"
  }
}

resource "aws_lb_target_group" "search-test" {
  name     = "search-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  stickiness {
    type   = "lb_cookie"
  }
}

resource "aws_cloudwatch_log_group" "search-stage" {
  name = "/ecs/search-stage"
}

resource "aws_ecs_task_definition" "search-stage" {
  family = "search-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"
  container_definitions = templatefile("search.json",
    {
      jwt_public_key     = var.jwt_public_key
      orcid_update_uuid  = var.orcid_update_uuid
      orcid_update_url   = var.orcid_update_url
      orcid_update_token = var.orcid_update_token
      orcid_url          = var.orcid_url
      volpino_url        = var.volpino_url
      homepage_url       = var.homepage_url
      commons_url        = var.commons_url
      jwt_host           = var.jwt_host
      api_url            = var.api_url
      fabrica_url        = var.fabrica_url
      data_url           = var.data_url
      cdn_url            = var.cdn_url
      sitemaps_url       = var.sitemaps_url
      sitemaps_bucket_url = var.sitemaps_bucket_url
      secret_key_base    = var.secret_key_base
      memcache_servers   = var.memcache_servers
      sentry_dsn         = var.sentry_dsn
      gabba_cookie       = var.gabba_cookie
      gabba_url          = var.gabba_url
      version            = var.doi-metadata-search_tags["sha"]
    })
}

resource "aws_lb_listener_rule" "search-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 89

  action {
    type             = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host = [aws_route53_record.akita-stage.name]
      path = ""
    }  
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search-stage.name]
  }
}

resource "aws_lb_listener_rule" "search-test" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 89

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.search-test.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search-test.name]
  }
}

resource "aws_route53_record" "search-stage" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "search.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-search-stage" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "search.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "search-test" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "search.test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.test.dns_name]
}

resource "aws_route53_record" "split-search-test" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "search.test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.test.dns_name]
}
