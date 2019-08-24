provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

provider "aws" {
  # us-east-1 instance
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
  alias = "use1"
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name = "datacite.org"
  private_zone = true
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

data "aws_ecs_cluster" "stage" {
  cluster_name = "stage"
}

data "aws_iam_role" "ecs_service" {
  name = "ecs_service"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_lb" "default" {
  name = "${var.lb_name}"
}

data "aws_lb_listener" "default" {
  load_balancer_arn = "${data.aws_lb.default.arn}"
  port = 443
}

data "template_file" "doi_task" {
  template = "${file("doi.json")}"

  vars {
    orcid_url          = "${var.orcid_url}"
    api_url            = "${var.api_url}"
    eventdata_url      = "${var.eventdata_url}"
    search_url         = "${var.search_url}"
    cdn_url            = "${var.cdn_url}"
    sentry_dsn         = "${var.sentry_dsn}"
    public_key         = "${var.public_key}"
    alb_public_key     = "${var.alb_public_key}"
    jwt_public_key     = "${var.jwt_public_key}"
    tracking_id        = "${var.tracking_id}"
    version            = "${var.bracco_tags["version"]}"
  }
}
