resource "aws_lb_listener_rule" "mds-fixed" {
  listener_arn = data.aws_lb_listener.default-http.arn
  priority     = 15

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mds.arn
  }

  condition {
    host_header {
      values = ["mds-fixed.datacite.org"]
    }
  }
}

// resource "aws_route53_record" "split-main" {
//    zone_id = "${data.aws_route53_zone.internal.zone_id}"
//    name = "main.datacite.org"
//    type = "CNAME"
//    ttl = "${var.ttl}"
//    records = ["${data.aws_lb.default.dns_name}"]
// }

resource "aws_route53_record" "split-main" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "main.datacite.org"
   type = "A"
   ttl = var.ttl
   records = ["10.0.20.195"]
}

resource "aws_s3_bucket" "mds-fixed" {
    bucket = "mds-fixed.datacite.org"
    acl = "public-read"
    policy = templatefile("s3_cloudfront.json", {
      bucket_name = "mds-fixed.datacite.org"
    })

    tags = {
        Name = "mds-fixed.datacite.org"
    }

    versioning {
        enabled = true
    }
}

resource "aws_globalaccelerator_accelerator" "mds" {
  name            = "mds"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled   = false
    // flow_logs_s3_bucket = "mds-fixed"
    // flow_logs_s3_prefix = "flow-logs/"
  }
}

resource "aws_globalaccelerator_listener" "mds" {
  accelerator_arn = aws_globalaccelerator_accelerator.mds.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "mds" {
  listener_arn = aws_globalaccelerator_listener.mds.id

  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id = data.aws_lb.default.arn
    weight      = 100
  }
}
