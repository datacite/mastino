module "waf" {
  source  = "trussworks/waf/aws"
  version = "1.2.0"
  
  environment                         = "${var.environment}"
  associate_alb                       = true
  alb_arn                             = "${data.aws_lb.default.arn}"
  wafregional_rule_f5_id              = "${var.wafregional_rule_id}"
  ips_disallow                        = "${var.waf_ips_diallow}"
  ip_rate_limit                       = "${var.waf_ip_rate_limit}"
}