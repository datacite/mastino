resource "aws_lb_listener_rule" "search" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 89

  action {
    type             = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host = "commons.datacite.org"
      path = "/"
      query = ""
    }  
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search.name]
  }
}

resource "aws_route53_record" "search" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "search.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split-search" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "search.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = [data.aws_lb.default.dns_name]
}

resource "aws_lb_listener_rule" "user-agent" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 81

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The user-agent was found."
      status_code  = "200"
    }
  }

  condition {
    http_header {
      http_header_name = "user-agent"
      values           = ["*Googlebot*", "curl*"]
    }
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search.name]
  }

  condition {
    field  = "path-pattern"
    values = ["/user-agent*"]
  }
}

// Old solr search interfaces
resource "aws_lb_listener_rule" "solr-api" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 80

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This resource is no longer available."
      status_code  = "410"
    }
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search.name]
  }

  condition {
    field  = "path-pattern"
    values = ["/api*"]
  }
}

resource "aws_lb_listener_rule" "solr-ui" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 82

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This resource is no longer available."
      status_code  = "410"
    }
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search.name]
  }

  condition {
    field  = "path-pattern"
    values = ["/ui*"]
  }
}
