module "waf" {
  source  = "trussworks/waf/aws"
  version = "1.2.0"
  
  environment                         = "${var.environment}"
  associate_alb                       = true
  alb_arn                             = "${data.aws_lb.default.arn}"
  wafregional_rule_f5_id              = "${var.wafregional_rule_id}"
  ips_disallow                        = "${var.waf_ips_disallow}"
  regex_path_disallow_pattern_strings = "${var.waf_regex_path_disallow_pattern_strings}"
  regex_host_allow_pattern_strings    = "${var.waf_regex_host_allow_pattern_strings}"
  ip_rate_limit                       = "${var.waf_ip_rate_limit}"
}