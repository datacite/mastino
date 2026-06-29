locals {
  legacy_api_410_response = {
    content_type = "application/json"
    message_body = "{\"errors\":[{\"status\":\"410\",\"title\":\"Gone\",\"detail\":\"Legacy REST API v1 endpoint deprecated. Use /dois, /providers, or /clients instead. See https://support.datacite.org/docs/datacite-rest-api-legacy-endpoints-deprecation\"}]}"
    status_code  = "410"
  }

  legacy_api_410_path_patterns = ["/works*", "/members*", "/data-centers*"]
}

resource "aws_lb_listener_rule" "api-legacy-endpoints-410-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 44

  action {
    type = "fixed-response"

    fixed_response {
      content_type = local.legacy_api_410_response.content_type
      message_body = local.legacy_api_410_response.message_body
      status_code  = local.legacy_api_410_response.status_code
    }
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }

  condition {
    path_pattern {
      values = local.legacy_api_410_path_patterns
    }
  }
}
