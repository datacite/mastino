// resource "aws_lb" "default" {
//   name = "lb-default"
//   internal = false
//   subnets = ["${data.aws_subnet.datacite-public.id}", "${data.aws_subnet.datacite-public-alt.id}"]
//   security_groups = ["${data.aws_security_group.datacite-public.id}"]

//   enable_deletion_protection = true

//   access_logs {
//     bucket = "${aws_s3_bucket.logs.bucket}"
//     prefix = "lb"
//     enabled = true
//   }

//   tags {
//     Environment = "default"
//     Name = "lb"
//   }
// }

// resource "aws_s3_bucket" "logs" {
//   bucket = "logs.datacite.org"
//   acl    = "private"
//   policy = "${data.template_file.logs.rendered}"
//   tags {
//       Name = "lb"
//   }
// }

// resource "aws_lb_listener" "default" {
//   load_balancer_arn = "${aws_lb.default.id}"
//   port              = "443"
//   protocol          = "HTTPS"
//   ssl_policy        = "ELBSecurityPolicy-2016-08"
//   certificate_arn   = "${data.aws_acm_certificate.default.arn}"

//   default_action {
//     target_group_arn = "${data.aws_lb_target_group.mds.id}"
//     type             = "forward"
//   }
// }

// resource "aws_lb_listener" "default-http" {
//   load_balancer_arn = "${aws_lb.default.id}"
//   port              = "80"
//   protocol          = "HTTP"

//   default_action {
//     target_group_arn = "${data.aws_lb_target_group.http-redirect.id}"
//     type             = "forward"
//   }
// }
