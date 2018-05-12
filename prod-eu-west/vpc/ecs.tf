resource "aws_instance" "ecs-solr" {
    count = 2
    ami = "${var.ecs_ami["eu-west-1"]}"
    instance_type = "m4.2xlarge"
    vpc_security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
    subnet_id = "${data.aws_subnet.datacite-private.id}"
    key_name = "${var.key_name}"
    user_data = "${element(data.template_cloudinit_config.ecs-solr-user-data.*.rendered, count.index)}"
    iam_instance_profile = "${data.aws_iam_instance_profile.ecs_instance.name}"
    root_block_device {
        volume_size = 300
        volume_type = "gp2"
    }
    tags {
        Name = "ECS${count.index + 1}"
        Group = "ECS-Solr"
    }
    lifecycle {
        create_before_destroy = "true"
    }
}

resource "aws_route53_record" "internal-ecs" {
    count = 2
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "ecs${count.index + 1}.datacite.org"
    type = "A"
    ttl = "${var.ttl}"
    records = ["${element(aws_instance.ecs-solr.*.private_ip, count.index)}"]
}

resource "librato_space" "ecs" {
    name = "ECS"
}

resource "librato_space_chart" "ecs-cpu-reservation" {
  name = "ECS CPUReservation"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ecs.id}"
  type = "line"

  stream {
    metric = "AWS.ECS.CPUReservation"
    source = "${var.region}.default"
  }
}

resource "librato_space_chart" "ecs-cpu-utilization" {
  name = "ECS CPUUtilization"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ecs.id}"
  type = "line"

  stream {
    metric = "AWS.ECS.CPUUtilization"
    source = "${var.region}.default.*"
  }
}

resource "librato_space_chart" "ecs-memory-reservation" {
  name = "ECS MemoryReservation"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ecs.id}"
  type = "line"

  stream {
    metric = "AWS.ECS.MemoryReservation"
    source = "${var.region}.default"
  }
}

resource "librato_space_chart" "ecs-memory-utilization" {
  name = "ECS MemoryUtilization"
  label = "Percent"
  max = "100"
  space_id = "${librato_space.ecs.id}"
  type = "line"

  stream {
    metric = "AWS.ECS.MemoryUtilization"
    source = "${var.region}.default.*"
  }
}

// resource "librato_alert" "ecs-cpu-reservation" {
//   name = "ecs.cpu-reservation"
//   description = "Reserved CPU more than 90%"
//   rearm_seconds = "86400"
//   services = ["${librato_service.slack.id}"]
//   condition {
//     type = "above"
//     threshold = 90
//     duration = 300
//     metric_name = "AWS.ECS.CPUReservation"
//     source = "${var.region}.default"
//   }
// }

// resource "librato_alert" "ecs-cpu-utilization" {
//   name = "ecs.cpu-utilization"
//   description = "Utilized CPU more than 90%"
//   rearm_seconds = "3600"
//   services = ["${librato_service.slack.id}"]
//   condition {
//     type = "above"
//     threshold = 90
//     duration = 300
//     metric_name = "AWS.ECS.CPUUtilization"
//     source = "${var.region}.default.*"
//   }
// }

/* resource "librato_alert" "ecs-memory-reservation" {
  name = "ecs.memory-reservation"
  description = "Reserved memory more than 90%"
  rearm_seconds = "86400"
  services = ["${librato_service.slack.id}"]
  condition {
    type = "above"
    threshold = 90
    duration = 300
    metric_name = "AWS.ECS.MemoryReservation"
    source = "${var.region}.default"
  }
} */

/* resource "librato_alert" "ecs-memory-utilization" {
  name = "ecs.memory-utilization"
  description = "Utilized memory more than 90%"
  rearm_seconds = "3600"
  services = ["${librato_service.slack.id}"]
  condition {
    type = "above"
    threshold = 90
    duration = 900
    metric_name = "AWS.ECS.MemoryUtilization"
    source = "${var.region}.default.*"
  }
} */

/* resource "librato_alert" "ecs3-disk" {
  name = "ecs3.disk"
  description = "Disk space below 10%"
  rearm_seconds = "3600"
  services = ["${librato_service.slack.id}"]
  condition {
    type = "below"
    threshold = 10
    duration = 300
    metric_name = "librato.df.root.percent_bytes.free"
    summary_function = "min"
    source = "ecs3.datacite.org"
  }
} */

