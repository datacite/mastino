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

// locals {
//   target_group_solr_id = "${element(split("/", aws_lb_target_group.solr.arn_suffix), 2)}"
//   source_solr = "app-lb-${local.lb_listener_default_id}.targetgroup-solr-${local.target_group_solr_id}"
// }

// resource "librato_space_chart" "alb-solr-overlayed-request-time" {
//   name = "Request Time Solr overlayed"
//   label = "Milliseconds"
//   space_id = "${librato_space.lb.id}"
//   type = "line"

//   stream {
//     metric = "AWS.ApplicationELB.TargetResponseTime"
//     source = "${local.source_solr}"
//     transform_function = "x*1000"
//     color = "#61bb4b"
//   }
//   stream {
//     metric = "AWS.ApplicationELB.TargetResponseTime"
//     source = "${local.source_api}"
//     transform_function = "x*1000"
//     color = "#235a94"
//   }
//   stream {
//     metric = "AWS.ApplicationELB.TargetResponseTime"
//     source = "${local.source_search}"
//     transform_function = "x*1000"
//     color = "#e68417"
//   }
// }

// resource "librato_space_chart" "alb-solr-overlayed-request-types" {
//   name = "Request Types Solr overlayed"
//   label = "Requests"
//   space_id = "${librato_space.lb.id}"
//   type = "stacked"

//   stream {
//     metric = "AWS.ApplicationELB.RequestCount"
//     source = "${local.source_solr}"
//     color = "#61bb4b"
//   }
//   stream {
//     metric = "AWS.ApplicationELB.RequestCount"
//     source = "${local.source_api}"
//     color = "#235a94"
//   }
//   stream {
//     metric = "AWS.ApplicationELB.RequestCount"
//     source = "${local.source_search}"
//     color = "#e68417"
//   }
// }

// resource "librato_space_chart" "alb-solr-request-time" {
//   name = "Request Time Solr"
//   label = "Milliseconds"
//   space_id = "${librato_space.lb.id}"
//   type = "line"

//   stream {
//     metric = "AWS.ApplicationELB.TargetResponseTime"
//     source = "${local.source_solr}"
//     transform_function = "x*1000"
//   }
// }

// resource "librato_space_chart" "alb-solr-request-types" {
//   name = "Request Types Solr"
//   label = "Requests"
//   space_id = "${librato_space.lb.id}"
//   type = "stacked"

//   stream {
//     metric = "AWS.ApplicationELB.HTTPCode_Target_2XX_Count"
//     source = "${local.source_solr}"
//     color = "#61bb4b"
//   }
//   stream {
//     metric = "AWS.ApplicationELB.HTTPCode_Target_3XX_Count"
//     source = "${local.source_solr}"
//     color = "#235a94"
//   }
//   stream {
//     metric = "AWS.ApplicationELB.HTTPCode_Target_4XX_Count"
//     source = "${local.source_solr}"
//     color = "#e68417"
//   }
//   stream {
//     metric = "AWS.ApplicationELB.HTTPCode_Target_5XX_Count"
//     source = "${local.source_solr}"
//     color = "#e63c2f"
//   }
// }
