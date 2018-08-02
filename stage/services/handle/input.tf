provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

data "aws_lb" "stage" {
  name = "${var.lb_name}"
}

data "aws_lb_listener" "stage" {
  load_balancer_arn = "${data.aws_lb.stage.arn}"
  port = 443
}

data "template_file" "handle_task" {
  template = "${file("handle.json")}"

  vars {
    mysql_host = "${var.mysql_host}"
    mysql_user = "${var.mysql_user}"
    mysql_password = "${var.mysql_password}"
    handle_svr_private_key = "${var.handle_svr_private_key}"
    handle_svr_public_key = "${var.handle_svr_public_key}"
  }
}
