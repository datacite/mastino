resource "aws_lb" "crosscite" {
  name = "crosscite"
  internal = false
  subnets = [data.aws_subnet.datacite-public.id, data.aws_subnet.datacite-public-alt.id]
  security_groups = [data.aws_security_group.datacite-public.id]

  enable_deletion_protection = true

  access_logs {
    bucket = data.aws_s3_bucket.logs.bucket
    prefix = "crosscite"
    enabled = true
  }

  tags = {
    Environment = "default"
    Name = "crosscite"
  }
}

resource "aws_lb_listener" "crosscite" {
  load_balancer_arn = aws_lb.crosscite.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.crosscite.arn

  default_action {
     target_group_arn = data.aws_lb_target_group.content-negotation.id
     type             = "forward"
  }

}

resource "aws_lb_listener" "crosscite-http" {
  load_balancer_arn = aws_lb.crosscite.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
