# resource "aws_ecs_service" "analytics-stage" {
#   name = "analytics-stage"
#   cluster = data.aws_ecs_cluster.stage.id
#   launch_type = "FARGATE"
#   task_definition = aws_ecs_task_definition.analytics-stage.arn
#   desired_count = 1

#   network_configuration {
#     security_groups = [data.aws_security_group.datacite-private.id]
#     subnets         = [
#       data.aws_subnet.datacite-private.id,
#       data.aws_subnet.datacite-alt.id
#     ]
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.analytics-stage.id
#     container_name   = "analytics-stage"
#     container_port   = "8000"
#   }

#   service_registries {
#     registry_arn = aws_service_discovery_service.analytics-stage.arn
#   }

#   depends_on = [
#     data.aws_lb_listener.stage
#   ]
# }

# resource "aws_cloudwatch_log_group" "analytics-stage" {
#   name = "/ecs/analytics-stage"
# }

# resource "aws_ecs_task_definition" "analytics-stage" {
#   family = "analytics-stage"
#   execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
#   network_mode = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu = "2048"
#   memory = "4096"

#   container_definitions =  data.template_file.analytics_task.rendered
# }

# resource "aws_lb_target_group" "analytics-stage" {
#   name     = "analytics-stage"
#   port     = 8000
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id
#   target_type = "ip"

#   lifecycle {
#     create_before_destroy = true
#   }

#   health_check {
#     path = "/"
#     interval = 300
#     timeout = 120
#   }
# }

# resource "aws_lb_listener_rule" "analytics-stage" {
#   listener_arn = data.aws_lb_listener.stage.arn
#   # priority     = 90

#   lifecycle {
#     create_before_destroy = true
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.analytics-stage.arn
#   }

#   condition {
#     field  = "host-header"
#     values = [aws_route53_record.analytics-stage.name]
#   }
# }

resource "aws_route53_record" "analytics-stage" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "analytics.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.stage.dns_name]
}

# resource "aws_service_discovery_service" "analytics-stage" {
#   name = "analytics.stage"

#   health_check_custom_config {
#     failure_threshold = 3
#   }

#   dns_config {
#     namespace_id = var.namespace_id

#     dns_records {
#       ttl = 300
#       type = "A"
#     }
#   }
# }
