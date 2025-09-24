resource "aws_wafv2_ip_set" "nat" {
  name               = "natIPSet"
  description        = "NAT IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = [var.waf_nat_ip]
}

resource "aws_wafv2_web_acl" "prod-default" {
  name        = "prod-default"
  description = "Default web acl For protecting lb"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  custom_response_body {
    content = jsonencode(
      {
        errors = [
          {
            status = "403"
            title  = "Your request has been rate limited."
          },
        ]
      }
    )
    content_type = "APPLICATION_JSON"
    key          = "ratelimiterror"
  }

  rule {
    name     = "natIpSetAllow"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.nat.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "natIpSetAllow"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "prodRateLimitingRuleAuthenticated"
    priority = 2

    action {
      block {
        custom_response {
          custom_response_body_key = "ratelimiterror"
          response_code            = 403
        }
      }
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
      metric_name                = "prodRateLimitingRuleAuthenticated"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "isWorks"
    priority = 3

    action {
      block {
        custom_response {
          response_code            = 403
          custom_response_body_key = "ratelimiterror"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 400
        aggregate_key_type = "IP"
        scope_down_statement {
          byte_match_statement {
            search_string = "/works"
            field_to_match {
              uri_path {}
            }
            positional_constraint = "EXACTLY"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "is_works"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "isGraphql"
    priority = 4

    action {
      block {
        custom_response {
          response_code            = 403
          custom_response_body_key = "ratelimiterror"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 200
        aggregate_key_type = "IP"
        scope_down_statement {
          byte_match_statement {
            search_string = "/graphql"
            field_to_match {
              uri_path {}
            }
            positional_constraint = "EXACTLY"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "is_graphql"
      sampled_requests_enabled   = true
    }
  }

   rule {
    name     = "prodRateLimitWithEmail"
    priority = 5

    action {
      block {
        custom_response {
          response_code = 403
          custom_response_body_key = "ratelimiterror"
        }
      }
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
      metric_name                = "prodRateLimitWithEmail"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "prodRateLimitUnauthenticated"
    priority = 6

    action {
      block {
        custom_response {
          response_code = 403
          custom_response_body_key = "ratelimiterror"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 500
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "prodRateLimitUnauthenticated"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "defaultv2"
    sampled_requests_enabled   = true
  }
}


resource "aws_wafv2_web_acl_association" "prod-lb" {
  resource_arn = data.aws_lb.default.arn
  web_acl_arn  = aws_wafv2_web_acl.prod-default.arn
}
resource "aws_wafv2_web_acl_association" "crosscite-lb" {
  resource_arn = data.aws_lb.crosscite.arn
  web_acl_arn  = aws_wafv2_web_acl.prod-default.arn
}
