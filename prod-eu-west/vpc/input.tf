provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

provider "librato" {
  email = "${var.librato_email}"
  token = "${var.librato_token}"
}

data "aws_security_group" "datacite-public" {
  id = "${var.security_group_public_id}"
}

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_private_id}"
}

data "aws_subnet" "datacite-public" {
  id = "${var.subnet_datacite-public_id}"
}

data "aws_subnet" "datacite-private" {
  id = "${var.subnet_datacite-private_id}"
}

data "aws_subnet" "datacite-public-alt" {
  id = "${var.subnet_datacite-public-alt_id}"
}

data "aws_subnet" "datacite-alt" {
  id = "${var.subnet_datacite-alt_id}"
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name = "datacite.org"
  private_zone = true
}

data "aws_lb" "default" {
  name = "${var.lb_name}"
}

data "aws_lb_listener" "default" {
  load_balancer_arn = "${data.aws_lb.default.arn}"
  port = 443
}

data "aws_ecs_cluster" "default" {
  cluster_name = "default"
}

data "aws_acm_certificate" "default" {
  domain = "*.datacite.org"
  statuses = ["ISSUED"]
}

data "template_cloudinit_config" "ecs-solr-user-data" {
  count = 2
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-boothook"
    content      = "${element(data.template_file.ecs-solr-user-data-boothook.*.rendered, count.index)}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "${element(data.template_file.ecs-solr-user-data-cfg.*.rendered, count.index)}"
  }
}

data "template_file" "ecs-solr-user-data-cfg" {
  count = 2
  template = "${file("user_data.cfg")}"

  vars {
    hostname     = "ecs${count.index}"
    fqdn         = "ecs${count.index}.datacite.org"
  }
}

data "template_file" "ecs-solr-user-data-boothook" {
  count = 2
  template = "${file("user_data_solr.sh")}"

  vars {
    cluster_name       = "default"
    hostname           = "solr${count.index + 1}.datacite.org"
    solr_port          = 40195
    mysql_host         = "${var.mysql_host}"
    mysql_database     = "${var.mysql_database}"
    mysql_user         = "${var.mysql_user}"
    mysql_password     = "${var.mysql_password}"
    test_prefix        = "${var.test_prefix}"
    sorl_host          = "solr${count.index + 1}.datacite.org"
    solr_home          = "${var.solr_home}"
    solr_url           = "${var.solr_url}"
    solr_user          = "${var.solr_user}"
    solr_password      = "${var.solr_password}"
    syslog_host        = "${var.syslog_host}"
    syslog_port        = "${var.syslog_port}"
    solr_version       = "${lookup(var.search_tags, count.index)}"
    solr_tag           = "${lookup(var.search_tags, count.index)}"
  }
}

data "aws_iam_instance_profile" "ecs_instance" {
  name  = "ecs_instance"
}

data "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"
}

data "aws_lb_target_group" "http-redirect" {
  name = "http-redirect"
}

data "aws_lb_target_group" "mds" {
  name = "mds"
}

data "template_file" "logs" {
  template = "${file("s3_lb_write_access.json")}"

  vars {
    bucket_name = "logs.datacite.org"
  }
}
