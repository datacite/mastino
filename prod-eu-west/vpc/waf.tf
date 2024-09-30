resource "aws_wafregional_ipset" "nat" {
  name = "natIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_nat_ip
  }
}

resource "aws_wafregional_ipset" "whitelist" {
  name = "whitelistIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_whitelisted_ip
  }
}

resource "aws_wafregional_ipset" "blacklist" {
  name = "blacklistIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_blacklisted_ip
  }
}

resource "aws_wafregional_rate_based_rule" "rate" {
  depends_on  = [aws_wafregional_ipset.nat, aws_wafregional_ipset.whitelist]
  name        = "natWAFRule"
  metric_name = "natWAFRule"

  rate_key   = "IP"
  rate_limit = 3000

  predicate {
    data_id = aws_wafregional_ipset.nat.id
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_ipset.whitelist.id
    negated = true
    type    = "IPMatch"
  }
}

resource "aws_wafregional_byte_match_set" "cnUriMatch" {
  name = "cnUriMatch"

  byte_match_tuples {
    text_transformation   = "NONE"
    target_string         = "data.crosscite.org"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "host"
    }
  }
}

resource "aws_wafregional_rate_based_rule" "cnWAFRule" {
  depends_on  = [aws_wafregional_byte_match_set.cnUriMatch]
  name        = "cnWAFRule"
  metric_name = "cnWAFRule"

  rate_key   = "IP"
  rate_limit = 1000

  predicate {
    data_id = aws_wafregional_byte_match_set.cnUriMatch.id
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_wafregional_rule" "block" {
  name        = "blockWAFRule"
  metric_name = "blockWAFRule"

  predicate {
    type    = "IPMatch"
    data_id = aws_wafregional_ipset.blacklist.id
    negated = false
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
    rule_id  = aws_wafregional_rate_based_rule.rate.id
    type     = "RATE_BASED"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 2
    rule_id  = aws_wafregional_rule.block.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 3
    rule_id  = aws_wafregional_rate_based_rule.cnWAFRule.id
    type     = "RATE_BASED"
  }

  lifecycle {
    ignore_changes = [
      rule
    ]
  }
}

resource "aws_wafregional_web_acl_association" "default" {
  resource_arn = data.aws_lb.default.arn
  web_acl_id   = aws_wafregional_web_acl.default.id
}

resource "aws_wafregional_web_acl_association" "crosscite-default" {
  resource_arn = data.aws_lb.crosscite.arn
  web_acl_id   = aws_wafregional_web_acl.default.id
}

// WAF v2 Setup

resource "aws_wafv2_web_acl" "prod-default" {
  name        = "prod-default"
  description = "Default web acl For protecting lb"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "prodRateLimitingRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 3000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "prodRateLimitingRule"
      sampled_requests_enabled   = false
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "defaultv2"
    sampled_requests_enabled   = false
  }
}
