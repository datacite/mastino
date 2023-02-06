resource "aws_instance" "clickhouse-stage" {
  ami = var.ami[var.region]
  subnet_id =  var.subnet_datacite-private_id
  instance_type = "t2.medium"
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.name
  vpc_security_group_ids = [var.security_group_id]
  key_name = var.key_name
  user_data = file("ec2_launch_script.sh")
  tags = {
    Name = "clickhouse-stage"
  }
}

resource "aws_ecs_task_definition" "clickhouse-stage" {
  family = "clickhouse-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu = "1024"
  memory = "2048"

  container_definitions = templatefile("clickhouse.json", {
    clickhouse_config  = base64encode(data.clickhouse-config.content)
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
  })

  volume {
    name = "clickhouse-stage"
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

  volume {
    name = "clickhouse-config-stage"
  }

}

resource "aws_ecs_service" "clickhouse-stage" {
  name = "clickhouse-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "EC2"
  task_definition = aws_ecs_task_definition.clickhouse-stage.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.clickhouse-stage.arn
  }
}

resource "aws_service_discovery_service" "clickhouse-stage" {
  name = "clickhouse.stage"

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

resource "aws_route53_record" "clickhouse-stage" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "clickhouse.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [aws_instance.clickhouse-stage.private_dns]
}

resource "aws_cloudwatch_log_group" "clickhouse-stage" {
  name = "/ecs/clickhouse-stage"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "clickhouse-stage-instance-profile"
  role = aws_iam_role.ecs-instance-role.id
}

resource "aws_iam_role" "ecs-instance-role" {
  name = "clickhouse-stage-instance-role"
  path = "/"
  assume_role_policy = file("ec2-assume-policy.json")
}

resource "aws_iam_policy" "ecs-ec2-policy" {
  name = "ecs-ec2-policy-clickhouse-stage"
  policy = file("ecs-policy.json")
}

resource "aws_iam_policy" "ecs-rexray-policy" {
  name = "ecs-rexray-policy-clickhouse-stage"
  policy = file("rexray-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-instance-policy-attachment" {
  role = aws_iam_role.ecs-instance-role.name
  policy_arn = aws_iam_policy.ecs-ec2-policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs-rexray-policy-attachment" {
  role = aws_iam_role.ecs-instance-role.name
  policy_arn = aws_iam_policy.ecs-rexray-policy.arn
}
