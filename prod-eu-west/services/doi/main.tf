// resource "aws_ecs_service" "doi" {
//   name = "doi"
//   cluster = "${data.aws_ecs_cluster.default.id}"
//   launch_type = "FARGATE"
//   platform_version = "1.4.0"
//   task_definition = "${aws_ecs_task_definition.doi.arn}"
// 
//   # Create service with 2 instances to start
//  desired_count = 0
// 
//   # Allow external changes without Terraform plan difference
//   lifecycle {
//     ignore_changes = ["desired_count"]
//   }
// 
//   # give container time to start up
//   health_check_grace_period_seconds = 1800
// 
//   network_configuration {
//     security_groups = ["${data.aws_security_group.datacite-private.id}"]
//     subnets         = [
//       "${data.aws_subnet.datacite-private.id}",
//       "${data.aws_subnet.datacite-alt.id}"
//     ]
//   }
// 
//   load_balancer {
//     target_group_arn = "${aws_lb_target_group.doi.id}"
//     container_name   = "doi"
//     container_port   = "80"
//   }
// 
//   service_registries {
//     registry_arn = "${aws_service_discovery_service.doi.arn}"
//   }
// 
//   depends_on = [
//     "data.aws_lb_listener.default",
//   ]
// }
// 
// resource "aws_appautoscaling_target" "doi" {
//   max_capacity       = 6
//   min_capacity       = 2
//   resource_id        = "service/default/${aws_ecs_service.doi.name}"
//   scalable_dimension = "ecs:service:DesiredCount"
//   service_namespace  = "ecs"
// }
// 
// resource "aws_appautoscaling_policy" "doi_scale_up" {
//   name               = "scale-up"
//   policy_type        = "StepScaling"
//   resource_id        = "${aws_appautoscaling_target.doi.resource_id}"
//   scalable_dimension = "${aws_appautoscaling_target.doi.scalable_dimension}"
//   service_namespace  = "${aws_appautoscaling_target.doi.service_namespace}"
// 
//   step_scaling_policy_configuration {
//     adjustment_type         = "ChangeInCapacity"
//     cooldown                = 300
//     metric_aggregation_type = "Maximum"
// 
//     step_adjustment {
//       metric_interval_lower_bound = 0
//       scaling_adjustment          = 1
//     }
//   }
// }
// 
// resource "aws_appautoscaling_policy" "doi_scale_down" {
//   name               = "scale-down"
//   policy_type        = "StepScaling"
//   resource_id        = "${aws_appautoscaling_target.doi.resource_id}"
//   scalable_dimension = "${aws_appautoscaling_target.doi.scalable_dimension}"
//   service_namespace  = "${aws_appautoscaling_target.doi.service_namespace}"
// 
//   step_scaling_policy_configuration {
//     adjustment_type         = "ChangeInCapacity"
//     cooldown                = 300
//     metric_aggregation_type = "Maximum"
// 
//     step_adjustment {
//       metric_interval_upper_bound = 0
//       scaling_adjustment          = -1
//     }
//   }
// }
// 
// resource "aws_cloudwatch_metric_alarm" "doi_cpu_scale_up" {
//   alarm_name          = "doi_cpu_scale_up"
//   comparison_operator = "GreaterThanOrEqualToThreshold"
//   evaluation_periods  = "2"
//   metric_name         = "CPUUtilization"
//   namespace           = "AWS/ECS"
//   period              = "120"
//   statistic           = "Average"
//   threshold           = "80"
// 
//   dimensions {
//     ClusterName = "default"
//     ServiceName = "${aws_ecs_service.doi.name}"
//   }
// 
//   alarm_description = "This metric monitors ecs cpu utilization"
//   alarm_actions     = ["${aws_appautoscaling_policy.doi_scale_up.arn}"]
// }
// 
// resource "aws_cloudwatch_metric_alarm" "doi_cpu_scale_down" {
//   alarm_name          = "doi_cpu_scale_down"
//   comparison_operator = "LessThanOrEqualToThreshold"
//   evaluation_periods  = "2"
//   metric_name         = "CPUUtilization"
//   namespace           = "AWS/ECS"
//   period              = "120"
//   statistic           = "Average"
//   threshold           = "20"
// 
//   dimensions {
//     ClusterName = "default"
//     ServiceName = "${aws_ecs_service.doi.name}"
//   }
// 
//   alarm_description = "This metric monitors ecs cpu utilization"
//   alarm_actions     = ["${aws_appautoscaling_policy.doi_scale_down.arn}"]
// }
// 
// resource "aws_cloudwatch_log_group" "doi" {
//   name = "/ecs/doi"
// }
// 
// resource "aws_ecs_task_definition" "doi" {
//   family = "doi"
//   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
//   network_mode = "awsvpc"
//   requires_compatibilities = ["FARGATE"]
//   cpu = "1024"
//   memory = "4096"
// 
//   container_definitions =  "${data.template_file.doi_task.rendered}"
// }
// 
// resource "aws_lb_target_group" "doi" {
//   name     = "doi"
//   port     = 80
//   protocol = "HTTP"
//   vpc_id   = "${var.vpc_id}"
//   target_type = "ip"
// 
//   health_check {
//     path = "/heartbeat"
//     interval = 120
//     timeout = 30
//   }
// }
// 
// resource "aws_lb_listener_rule" "doi-auth" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 30
// 
//   action {
//     type = "authenticate-oidc"
// 
//     authenticate_oidc {
//       authorization_endpoint = "https://auth.globus.org/v2/oauth2/authorize"
//       client_id              = "${var.oidc_client_id}"
//       client_secret          = "${var.oidc_client_secret}"
//       issuer                 = "https://auth.globus.org"
//       token_endpoint         = "https://auth.globus.org/v2/oauth2/token"
//       user_info_endpoint     = "https://auth.globus.org/v2/oauth2/userinfo"
//       on_unauthenticated_request = "authenticate"
//       scope                  = "openid profile email"
//     }
//   }
// 
//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.doi.arn}"
//   }
// 
//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.doi.name}"]
//   }
// 
//   condition {
//     field  = "path-pattern"
//     values = ["/authorize"]
//   }
// }
// 
// resource "aws_lb_listener_rule" "doi-clients" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 84
// 
//   action {
//     type = "redirect"
// 
//     redirect {
//       path        = "/"
//       protocol    = "HTTPS"
//       status_code = "HTTP_302"
//     }
//   }
// 
//   condition {
//     field  = "path-pattern"
//     values = ["/clients*"]
//   }
// }
// 
// resource "aws_lb_listener_rule" "doi" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 85
// 
//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.doi.arn}"
//   }
// 
//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.doi.name}"]
//   }
// }
// 
// resource "aws_route53_record" "doi" {
//     zone_id = "${data.aws_route53_zone.production.zone_id}"
//     name = "doi.datacite.org"
//     type = "CNAME"
//     ttl = "${var.ttl}"
//     records = ["${data.aws_lb.default.dns_name}"]
// }

resource "aws_route53_record" "doi" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "doi.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["cname.vercel-dns.com"]
}

// resource "aws_route53_record" "split-doi" {
//     zone_id = "${data.aws_route53_zone.internal.zone_id}"
//     name = "doi.datacite.org"
//     type = "CNAME"
//     ttl = "${var.ttl}"
//     records = ["${data.aws_lb.default.dns_name}"]
// }
// 
// resource "aws_service_discovery_service" "doi" {
//   name = "doi"
// 
//   health_check_custom_config {
//     failure_threshold = 3
//   }
// 
//   dns_config {
//     namespace_id = "${var.namespace_id}"
//
//     dns_records {
//       ttl = 300
//       type = "A"
//     }
//   }
// }
