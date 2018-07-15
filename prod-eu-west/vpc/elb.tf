resource "aws_lb" "alternate" {
  name = "lb-alternate"
  internal = false
  subnets = ["${data.aws_subnet.datacite-public.id}", "${data.aws_subnet.datacite-public-alt.id}"]
  security_groups = ["${data.aws_security_group.datacite-public.id}"]

  enable_deletion_protection = true

  access_logs {
    bucket = "${data.aws_s3_bucket.logs.bucket}"
    prefix = "lb-alternate"
    enabled = true
  }

  tags {
    Environment = "alternate"
    Name = "lb-alternate"
  }
}

resource "aws_lb_listener" "alternate" {
  load_balancer_arn = "${aws_lb.alternate.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.default.arn}"

  default_action {
    target_group_arn = "${data.aws_lb_target_group.mds.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "alternate-http" {
  load_balancer_arn = "${aws_lb.alternate.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${data.aws_lb_target_group.http-redirect-alternate.id}"
    type             = "forward"
  }
}
