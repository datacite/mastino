resource "aws_s3_bucket" "search-stage" {
    bucket = "search.test.datacite.org"
    acl = "public-read"
    policy = "${data.template_file.search-stage.rendered}"
    website {
        index_document = "index.html"
    }
    tags {
        Name = "Search Stage"
    }
}

resource "aws_ecs_service" "search-stage" {
  name = "search-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.search-stage.arn}"
  desired_count = 1
  iam_role        = "${aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.search-stage.id}"
    container_name   = "search-stage"
    container_port   = "80"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_lb_listener.test",
  ]
}

resource "aws_lb_target_group" "search-stage" {
  name     = "search-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  stickiness {
    type   = "lb_cookie"
  }
}

data "template_file" "search_stage_task" {
  template = "${file("search-stage.json")}"

  vars {
    jwt_secret_key     = "${var.jwt_secret_key}"
    jwt_public_key     = "${var.jwt_public_key}"
    jwt_host           = "${var.jwt_host}"
    orcid_update_uuid  = "${var.orcid_update_uuid}"
    orcid_update_url   = "${var.orcid_update_url}"
    orcid_update_token = "${var.orcid_update_token}"
    api_url            = "${var.api_url}"
    secret_key_base    = "${var.secret_key_base}"
    version            = "${var.doi-metadata-search_tags["sha"]}"
  }
}

resource "aws_ecs_task_definition" "search-stage" {
  family = "search-stage"
  container_definitions =  "${data.template_file.search_test_task.rendered}"
}

resource "aws_route53_record" "search-stage" {
   zone_id = "${aws_route53_zone.production.zone_id}"
   name = "search.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${aws_lb.test.dns_name}"]
}

resource "aws_route53_record" "split-search-stage" {
   zone_id = "${aws_route53_zone.internal.zone_id}"
   name = "search.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${aws_lb.test.dns_name}"]
}
