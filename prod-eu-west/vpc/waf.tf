// module "waf" {
//   source  = "trussworks/waf/aws"
//   version = "1.2.0"
  
//   environment                         = "${var.environment}"
//   associate_alb                       = true
//   alb_arn                             = "${data.aws_lb.default.arn}"
//   wafregional_rule_f5_id              = "${var.wafregional_rule_id}"
//   ips_disallow                        = "${var.waf_ips_disallow}"
//   regex_path_disallow_pattern_strings = "${var.waf_regex_path_disallow_pattern_strings}"
//   regex_host_allow_pattern_strings    = "${var.waf_regex_host_allow_pattern_strings}"
//   ip_rate_limit                       = "${var.waf_ip_rate_limit}"
// }

resource "aws_wafregional_ipset" "nat" {
  name = "natIPSet"

  ip_set_descriptors {
    type  = "IPV4"
    value = "${var.waf_nat_ip}"
  }
}

resource "aws_wafregional_rate_based_rule" "rate" {
  depends_on  = ["aws_wafregional_ipset.nat"]
  name        = "natWAFRule"
  metric_name = "natWAFRule"

  rate_key   = "IP"
  rate_limit = 3000

  predicates {
    data_id = "${aws_wafregional_ipset.nat.id}"
    negated = true
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "default" {
  name        = "default"
  metric_name = "default"

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = "${aws_wafregional_rate_based_rule.rate.id}"
    type     = "RATE_BASED"
  }
}

resource "aws_wafregional_web_acl_association" "default" {
  resource_arn = "${data.aws_lb.default.arn}"
  web_acl_id   = "${aws_wafregional_web_acl.default.id}"
}
