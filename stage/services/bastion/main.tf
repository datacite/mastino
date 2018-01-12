resource "aws_instance" "bastion-stage" {
    ami = "${var.ami["eu-west-1"]}"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
    subnet_id = "${data.aws_subnet.datacite-public.id}"
    key_name = "${var.key_name}"
    associate_public_ip_address = "true"
    user_data = "${data.template_file.bastion-stage-user-data-cfg.rendered}"
    tags {
        Name = "Bastion-Stage"
    }
}

resource "aws_eip" "bastion-stage" {
  vpc = "true"
}

resource "aws_eip_association" "bastion-stage" {
  instance_id = "${aws_instance.bastion-stage.id}"
  allocation_id = "${aws_eip.bastion.id}"
}

resource "aws_route53_record" "bastion-stage" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "${var.hostname}.datacite.org"
    type = "A"
    ttl = "${var.ttl}"
    records = ["${aws_instance.bastion-stage.public_ip}"]
}

resource "aws_route53_record" "split-bastion-stage" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "${var.hostname}.datacite.org"
    type = "A"
    ttl = "${var.ttl}"
    records = ["${aws_instance.bastion-stage.private_ip}"]
}
