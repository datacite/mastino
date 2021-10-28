resource "aws_instance" "clickhouse-ebs-stage" {  ami = var.ami[var.region]
  subnet_id =  var.subnet_datacite-private_id
  instance_type = "t2.medium"
  vpc_security_group_ids = [var.security_group_id]
  ebs_optimized = "false"
  source_dest_check = "false"
  user_data = "${data.template_file.clickhouse-ebs-user-data-cfg.rendered}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = "30"
    delete_on_termination = "true"
  }
  key_name = var.key_name
  tags {
    name = "clickhouse-ebs-stage"
  }
}

resource "aws_ecs_task_definition" "clickhouse-ebs-stage" {
  family = "clickhouse-ebs-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu = "1024"
  memory = "2048"

  container_definitions = templatefile("clickhouse-ebs.json", {
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
  })

  volume {
    name = "rexray-vol"
    docker_volume_configuration {
      scope = "shared"
      autoprovision = true
      driver = "rexray/ebs"
      driver_opts = {
        volumetype = "gp2"
        size = 40
      }
    }
  }
}

resource "aws_ecs_service" "clickhouse-ebs-stage" {
  name = "clickhouse-ebs-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "EC2"
  task_definition = aws_ecs_task_definition.clickhouse-ebs-stage.arn
  desired_count = 1

  # give container time to start up
  health_check_grace_period_seconds = 900

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.clickhouse-ebs-stage.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.clickhouse-ebs-stage.id
    container_name   = "clickhouse-ebs-stage"
    container_port   = "8123"
  }

  depends_on = [
    data.aws_lb_listener.stage
  ]
}

resource "aws_lb_target_group" "clickhouse-ebs-stage" {
  name     = "clickhouse-ebs-stage"
  port     = 8123
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "clickhouse-ebs-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 130

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clickhouse-ebs-stage.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.clickhouse-ebs-stage.name]
  }
}

resource "aws_service_discovery_service" "clickhouse-ebs-stage" {
  name = "clickhouse-ebs.stage"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl = 300
      type = "A"
    }
  }
}

resource "aws_route53_record" "clickhouse-ebs-stage" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "clickhouse-ebs.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-clickhouse-ebs-stage" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "clickhouse-ebs.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.stage.dns_name]
}

resource "aws_cloudwatch_log_group" "clickhouse-ebs-stage" {
  name = "/ecs/clickhouse-ebs-stage"
}

////////////////////

resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs-instance-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-instance-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    aws_iam_policy.ecs-rexray-policy.arn
  ])
   role = aws_iam_role.ecs-instance-role.name
   policy_arn = each.value
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs-instance-role.id
    provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "aws_iam_policy" "ecs-rexray-policy" {
    name        = "ecs-rexray-policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DetachVolume",
        "ec2:AttachVolume",
        "ec2:CopySnapshot",
        "ec2:DeleteSnapshot",
        "ec2:ModifyVolumeAttribute",
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeSnapshotAttribute",
        "ec2:CreateTags",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumeAttribute",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeVolumeStatus",
        "ec2:ModifySnapshotAttribute",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeVolumes",
        "ec2:CreateSnapshot"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs-service-role" {
  name = "ecs-service-role"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  role = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
