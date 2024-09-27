resource "aws_wafv2_web_acl" "stage-default" {
  name        = "stage-default"
  description = "Default web acl for protecting staging lb and testing rules"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "stageRateLimitingRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "stageRateLimitingRule"
      sampled_requests_enabled   = false
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "stage-default"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "stage-default" {
  resource_arn = data.aws_lb.stage.arn
  web_acl_arn  = aws_wafv2_web_acl.stage-default.arn
}
