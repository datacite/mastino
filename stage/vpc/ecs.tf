resource "aws_instance" "ecs-stage" {
    ami = "${var.ecs_ami["eu-west-1"]}"
    instance_type = "m5.large"
    vpc_security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
    subnet_id = "${data.aws_subnet.datacite-private.id}"
    key_name = "${var.key_name}"
    user_data = "${data.template_cloudinit_config.ecs-user-data.rendered}"
    iam_instance_profile = "${data.aws_iam_instance_profile.ecs_instance.name}"
    root_block_device {
        volume_size = 100
        volume_type = "gp2"
    }
    tags {
        Name = "ECS-Stage"
    }
    lifecycle {
        create_before_destroy = "true"
    }
}

resource "aws_ecs_cluster" "stage" {
  name = "stage"
}

resource "aws_route53_record" "internal-ecs-stage" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "ecs.stage.datacite.org"
    type = "A"
    ttl = "${var.ttl}"
    records = ["${aws_instance.ecs-stage.private_ip}"]
}
