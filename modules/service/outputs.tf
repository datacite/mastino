output "ecs_service_name" {
  value = aws_ecs_service.ecs-service.name
}

output "aws_lb_listener_arn" {
  value = aws_lb_listener.lb_listener.arn
}

output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.lb_target_group.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}