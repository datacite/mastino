resource "aws_lb" "us" {
  name = "lb-us"
  internal = false
  subnets = ["${data.aws_subnet.datacite-public.id}", "${data.aws_subnet.datacite-public-alt.id}"]
  security_groups = ["${data.aws_security_group.datacite-public.id}"]

  enable_deletion_protection = true

  access_logs {
    bucket = "${aws_s3_bucket.logs-us.bucket}"
    prefix = "lb"
    enabled = true
  }

  tags {
    Environment = "us"
    Name = "lb-us"
  }
}

resource "aws_s3_bucket" "logs-us" {
  bucket = "logs.us.datacite.org"
  acl    = "private"
  policy = "${data.template_file.logs-us.rendered}"
  tags {
      Name = "lb-us"
  }
}

resource "aws_lb_listener" "us" {
  load_balancer_arn = "${aws_lb.us.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.default.arn}"

  default_action {
    target_group_arn = "${data.aws_lb_target_group.data.id}"
    type             = "forward"
  }
}
