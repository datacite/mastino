resource "aws_wafv2_web_acl" "stage-default" {
  name        = "stage-default"
  description = "Default web acl for protecting staging lb and testing rules"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "stageRateLimitAuthenticated"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 3000
        aggregate_key_type = "IP"

        scope_down_statement {
          or_statement {
            statement {
              byte_match_statement {
                search_string = "bearer "
                field_to_match {
                  single_header {
                    name = "authorization"
                  }
                }
                positional_constraint = "STARTS_WITH"
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }
            statement {
              byte_match_statement {
                search_string = "basic "
                field_to_match {
                  single_header {
                    name = "authorization"
                  }
                }
                positional_constraint = "STARTS_WITH"
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "stageRateLimitAuthenticated"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "stageRateLimitWithEmail"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"

        scope_down_statement {
          or_statement {
            statement {
              byte_match_statement {
                search_string = "@"
                field_to_match {
                  single_header {
                    name = "user-agent"
                  }
                }
                positional_constraint = "CONTAINS"
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
            statement {
              byte_match_statement {
                search_string = "mailto="
                field_to_match {
                  query_string {}
                }
                positional_constraint = "CONTAINS"
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "stageRateLimitWithEmail"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "RateLimitUnauthenticated"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 500
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "stageRateLimitUnauthenticated"
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
