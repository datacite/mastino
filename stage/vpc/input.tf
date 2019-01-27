provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
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

data "aws_acm_certificate" "test" {
  domain = "*.test.datacite.org"
  statuses = ["ISSUED"]
  most_recent = true
}

data "template_cloudinit_config" "ecs-user-data" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-boothook"
    content      = "${data.template_file.ecs-user-data-boothook.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.ecs-user-data-cfg.rendered}"
  }
}

data "template_file" "ecs-user-data-cfg" {
  template = "${file("user_data.cfg")}"

  vars {
    hostname     = "ecs-stage"
    fqdn         = "ecs.stage.datacite.org"
  }
}

data "template_file" "ecs-user-data-boothook" {
  template = "${file("user_data_solr.sh")}"

  vars {
    cluster_name       = "${var.cluster}"
    hostname           = "solr.test.datacite.org"
    solr_port          = 40195
    mysql_host         = "${var.mysql_host}"
    mysql_database     = "${var.mysql_database}"
    mysql_user         = "${var.mysql_user}"
    mysql_password     = "${var.mysql_password}"
    test_prefix        = "${var.test_prefix}"
    solr_home          = "${var.solr_home}"
    solr_url           = "${var.solr_url}"
    solr_user          = "${var.solr_user}"
    solr_password      = "${var.solr_password}"
    dd_api_key         = "${var.dd_api_key}"
    solr_version       = "${var.search_tags["sha"]}"
    solr_tag           = "latest"
  }
}

data "aws_iam_instance_profile" "ecs_instance" {
  name  = "ecs_instance"
}

data "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"
}

data "aws_lb_target_group" "api-stage" {
  name = "api-stage"
}

data "aws_lb_target_group" "http-redirect-stage" {
  name = "http-redirect-stage"
}

data "template_file" "logs-stage" {
  template = "${file("s3_lb_write_access.json")}"

  vars {
    bucket_name = "logs.stage.datacite.org"
  }
}
