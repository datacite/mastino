resource "aws_lb" "stage" {
  name = "lb-stage"
  internal = false
  subnets = [data.aws_subnet.datacite-public.id, data.aws_subnet.datacite-public-alt.id]
  security_groups = [data.aws_security_group.datacite-public.id]
  idle_timeout = 200

  enable_deletion_protection = true

  access_logs {
    bucket = aws_s3_bucket.logs-stage.bucket
    prefix = "lb"
    enabled = false
  }

  tags = {
    Environment = "stage"
    Name = "lb-stage"
  }
}

resource "aws_lb" "crosscite-stage" {
  name = "crosscite-stage"
  internal = false
  subnets = [data.aws_subnet.datacite-public.id, data.aws_subnet.datacite-public-alt.id]
  security_groups = [data.aws_security_group.datacite-public.id]

  enable_deletion_protection = true

  access_logs {
    bucket = aws_s3_bucket.logs-stage.bucket
    prefix = "crosscite-stage"
    enabled = false
  }

  tags = {
    Environment = "stage"
    Name = "crosscite-stage"
  }
}

resource "aws_s3_bucket" "logs-stage" {
  bucket = "logs.stage.datacite.org"
  tags = {
      Name = "lb-stage"
  }

  lifecycle {
    ignore_changes = [ grant ]
  }
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs-stage.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  depends_on = [aws_s3_bucket_ownership_controls.logs]

  bucket = aws_s3_bucket.logs-stage.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs-stage.id
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_lb_listener" "stage" {
  load_balancer_arn = aws_lb.stage.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.stage.arn

  default_action {
    target_group_arn = data.aws_lb_target_group.api-stage.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "http-stage" {
  load_balancer_arn = aws_lb.stage.id
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