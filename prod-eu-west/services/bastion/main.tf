resource "aws_instance" "bastion" {
    ami = "${var.ami["eu-west-1"]}"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
    subnet_id = "${data.aws_subnet.datacite-public.id}"
    key_name = "${var.key_name}"
    associate_public_ip_address = "true"
    user_data = "${data.template_file.bastion-user-data-cfg.rendered}"
    tags {
        Name = "Bastion"
    }
}

resource "aws_eip" "bastion" {
  vpc = "true"
}

resource "aws_eip_association" "bastion" {
  instance_id = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion.id}"
}

resource "aws_route53_record" "bastion" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "${var.hostname}.datacite.org"
    type = "A"
    ttl = "${var.ttl}"
    records = ["${aws_instance.bastion.public_ip}"]
}

resource "aws_route53_record" "split-bastion" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "${var.hostname}.datacite.org"
    type = "A"
    ttl = "${var.ttl}"
    records = ["${aws_instance.bastion.private_ip}"]
}

resource "aws_security_group" "bastion" {
    name = "bastion"
    description = "Managed by Terraform"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["10.0.0.0/16", "10.1.0.0/16"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "bastion"
    }
}
