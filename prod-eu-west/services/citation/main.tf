
resource "aws_lb_target_group" "citation" {
  name        = "citation"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "citation" {
  listener_arn = data.aws_lb_listener.crosscite.arn
  priority     = 70

  action {
    type = "redirect"

    redirect {
      host        = "citation.doi.org"
      path        = "/#{path}"
      query       = "#{query}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [aws_route53_record.citation.name]
    }
  }
}

resource "aws_route53_record" "crosscite-apex" {
  zone_id = data.aws_route53_zone.crosscite.zone_id
  name    = "crosscite.org"
  type    = "A"

  alias {
    name                   = data.aws_lb.crosscite.dns_name
    zone_id                = data.aws_lb.crosscite.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "crosscite-www" {
  zone_id = data.aws_route53_zone.crosscite.zone_id
  name    = "www.crosscite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.crosscite.dns_name]
}


resource "aws_route53_record" "citation" {
  zone_id = data.aws_route53_zone.crosscite.zone_id
  name    = "citation.crosscite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.crosscite.dns_name]
}
