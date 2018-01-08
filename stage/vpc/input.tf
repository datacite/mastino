provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_id}"
}

data "aws_subnet" "datacite-private" {
  id = "${var.subnet_datacite-private_id}"
}

data "aws_subnet" "datacite-alt" {
  id = "${var.subnet_datacite-alt_id}"
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

/* data "aws_acm_certificate" "test" {
  domain = "*.test.datacite.org"
  statuses = ["ISSUED"]
}

data "template_cloudinit_config" "ecs-stage-user-data" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-boothook"
    content      = "${data.template_file.ecs-stage-user-data-boothook.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.ecs-stage-user-data-cfg.rendered}"
  }
}

data "template_file" "ecs-stage-user-data-cfg" {
  template = "${file("templates/user_data.cfg")}"

  vars {
    hostname     = "ecs-stage"
    fqdn         = "ecs.stage.datacite.org"
  }
}

data "template_file" "ecs-stage-user-data-boothook" {
  template = "${file("${path.module}/templates/user_data_solr.sh")}"

  vars {
    cluster_name       = "${var.cluster_test}"
    hostname           = "solr.test.datacite.org"
    solr_port          = 40195
    mysql_host         = "${var.mysql_test_host}"
    mysql_database     = "${var.mysql_test_database}"
    mysql_user         = "${var.mysql_test_user}"
    mysql_password     = "${var.mysql_test_password}"
    sorl_host          = "solr.test.datacite.org"
    solr_home          = "${var.solr_home}"
    solr_url           = "${var.solr_url_test}"
    solr_user          = "${var.solr_user_test}"
    solr_password      = "${var.solr_password_test}"
    syslog_host        = "${var.syslog_host}"
    syslog_port        = "${var.syslog_port}"
    version            = "${var.search_tags["sha"]}"
  }
}

data "aws_iam_instance_profile" "ecs_instance" {
  name = "ecs_instance"
}

data "aws_lb_target_group" "api-stage" {
  arn  = "${var.lb_tg_arn}"
  name = "${var.lb_tg_name}"
} */

data "template_file" "logs-stage" {
  template = "${file("s3_lb_write_access.json")}"

  vars {
    bucket_name = "logs.stage.datacite.org"
  }
}
