
resource "aws_security_group" "bastion" {
    name = "bastion"
    description = "Managed by Terraform"
    vpc_id = var.vpc_id

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

    tags = {
        Name = "bastion"
    }
}

resource "aws_instance" "bastion-2024" {
    ami = var.ami_2024["eu-west-1"]
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.bastion.id]
    subnet_id = data.aws_subnet.datacite-public.id
    key_name = var.key_name_2024
    associate_public_ip_address = "true"
    user_data = data.template_file.bastion-2024-user-data-cfg.rendered
    tags = {
        Name = "Bastion 2024"
    }
}

resource "aws_eip" "bastion-2024" {
  domain = "vpc"
}

resource "aws_eip_association" "bastion-2024" {
  instance_id = aws_instance.bastion-2024.id
  allocation_id = aws_eip.bastion-2024.id
}

resource "aws_route53_record" "bastion-2024" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "${var.hostname_2024}.datacite.org"
    type = "A"
    ttl = var.ttl
    records = ["54.74.52.52"]
#    records = [aws_instance.bastion-2024.public_ip]
}

resource "aws_route53_record" "split-bastion-2024" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "${var.hostname_2024}.datacite.org"
    type = "A"
    ttl = var.ttl
    records = [aws_instance.bastion-2024.private_ip]
}
