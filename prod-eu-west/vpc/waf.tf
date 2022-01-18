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

resource "aws_wafregional_regex_match_set" "cn-suri" {
  name = "cn-uri"

  regex_match_tuple {
    field_to_match {
      type = "URI"
    }

    regex_pattern_set_id = aws_wafregional_regex_pattern_set.example.id
    text_transformation  = "NONE"
  }
}

resource "aws_wafregional_regex_pattern_set" "cn-regex" {
  name                  = "cn-regex"
  regex_pattern_strings = ["data\.crosscite\.org"]
}

resource "aws_wafregional_rate_based_rule" "contentnegotiation-rate" {
  depends_on  = [aws_wafregional_regex_match_set.cn-uri]
  name        = "cnWAFRule"
  metric_name = "cnWAFRule"

  rate_key   = "IP"
  rate_limit = 1000

  predicate {
    data_id = aws_wafregional_regex_match_set.cn-uri.id
    negated = false
    type    = "IPMatch"
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
    rule_id  = aws_wafregional_rate_based_rule.contentnegotiation-rate.id
    type     = "RATE_BASED"
  }
}


resource "aws_wafregional_web_acl" "crosscite-default" {
  name        = "crosscite-default"
  metric_name = "crosscite-default"

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

    priority = 3
    rule_id  = aws_wafregional_rate_based_rule.rate_china.id
    type     = "REGULAR"
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
