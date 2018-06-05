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

resource "aws_cloudwatch_log_group" "solr" {
  name = "/ecs/solr"
}

resource "aws_route53_record" "internal-ecs" {
    count = 2
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "ecs${count.index + 1}.datacite.org"
    type = "A"
    ttl = "${var.ttl}"
    records = ["${element(aws_instance.ecs-solr.*.private_ip, count.index)}"]
}
