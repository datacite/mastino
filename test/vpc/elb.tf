resource "aws_lb" "test" {
  name = "lb-test"
  internal = false
  subnets = [data.aws_subnet.datacite-public.id, data.aws_subnet.datacite-public-alt.id]
  security_groups = [data.aws_security_group.datacite-public.id]
  idle_timeout = 200

  enable_deletion_protection = true

  access_logs {
    bucket = aws_s3_bucket.logs-test.bucket
    prefix = "lb-test"
    enabled = false
  }

  tags = {
    Environment = "test"
    Name = "lb-test"
  }
}

resource "aws_s3_bucket" "logs-test" {
  bucket = "logs.test.datacite.org"
  acl    = "private"
  policy = templatefile("s3_lb_write_access.json",
      {
        bucket_name = "logs.test.datacite.org"
      })
  tags = {
      Name = "lb-test"
  }
}

// resource "aws_lb_listener" "test" {
//   load_balancer_arn = aws_lb.test.id
//   port              = "443"
//   protocol          = "HTTPS"
//   ssl_policy        = "ELBSecurityPolicy-2016-08"
//   certificate_arn   = data.aws_acm_certificate.test.arn

//   default_action {
//     target_group_arn = data.aws_lb_target_group.api-test.id
//     type             = "forward"
//   }
// }

resource "aws_lb_listener" "http-test" {
  load_balancer_arn = aws_lb.test.id
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
