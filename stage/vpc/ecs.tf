/* resource "aws_instance" "ecs-stage" {
    ami = "${var.ecs_ami["eu-west-1"]}"
    instance_type = "m4.2xlarge"
    vpc_security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
    subnet_id = "${data.aws_subnet.datacite-private.id}"
    key_name = "mds"
    user_data = "${data.template_cloudinit_config.ecs-stage-user-data.rendered}"
    iam_instance_profile = "${data.aws_iam_instance_profile.ecs_instance.id}"
    root_block_device {
        volume_size = 100
        volume_type = "gp2"
    }
    tags {
        Name = "ecs-stage"
    }
    lifecycle {
        create_before_destroy = "true"
    }
}

resource "aws_route53_record" "internal-ecs-stage" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "ecs.stage.datacite.org"
    type = "A"
    ttl = "${var.ttl}"
    records = ["${aws_instance.ecs-stage.private_ip}"]
}

resource "aws_ecs_cluster" "stage" {
  name = "stage"
} */

/* resource "librato_space_chart" "ecs-stage-cpu-reservation" {
  name = "ECS Test CPUReservation"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ecs.id}"
  type = "line"

  stream {
    metric = "AWS.ECS.CPUReservation"
    source = "${var.region}.test"
  }
}

resource "librato_space_chart" "ecs-stage-cpu-utilization" {
  name = "ECS Test CPUUtilization"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ecs.id}"
  type = "line"

  stream {
    metric = "AWS.ECS.CPUUtilization"
    source = "${var.region}.test.*"
  }
}

resource "librato_space_chart" "ecs-stage-memory-reservation" {
  name = "ECS Test MemoryReservation"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ecs.id}"
  type = "line"

  stream {
    metric = "AWS.ECS.MemoryReservation"
    source = "${var.region}.test"
  }
}

resource "librato_space_chart" "ecs-stage-memory-utilization" {
  name = "ECS Test MemoryUtilization"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ecs.id}"
  type = "line"

  stream {
    metric = "AWS.ECS.MemoryUtilization"
    source = "${var.region}.test.*"
  }
} */

/* resource "librato_space_chart" "ecs-stage-disk" {
  name = "ECS Test Disk Free"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ec2.id}"
  type = "line"

  stream {
    metric = "librato.df.root.percent_bytes.free"
    source = "ecs.test.datacite.org"
  }
}

resource "librato_alert" "ecs-stage-disk" {
  name = "ecs-stage.disk"
  description = "Disk space below 5%"
  rearm_seconds = "3600"
  services = ["${librato_service.slack.id}"]
  condition {
    type = "below"
    threshold = 5
    duration = 300
    metric_name = "librato.df.root.percent_bytes.free"
    summary_function = "min"
    source = "ecs.test.datacite.org"
  }
} */
