provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
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

data "aws_lb" "stage" {
  name = "${var.lb_name}"
}

data "aws_lb_listener" "stage" {
  load_balancer_arn = "${data.aws_lb.stage.arn}"
  port = 443
}

# Template Task Definitions with a Password 
data "template_file" "neo_task" {
   template = "${file("task-definitions/neo.json")}"

   vars { 
      neo_password   = "${var.neo_password}"
      neo_url        = "${var.neo_url}"
   }
}


data "template_file" "wsgi_task" {
   template = "${file("task-definitions/wsgi.json")}"

   vars {
      proxy_url      = "${var.proxy_url}"
      neo_url        = "${var.neo_url}"
      neo_user       = "${var.neo_user}"
      neo_password   = "${var.neo_password}"
      redis_url      = "${var.redis_url}"
      datacite_url   = "${var.datacite_url}"
   }
}

data "template_file" "bagit_task" {
   template = "${file("task-definitions/bagit.json")}"

   vars {
      neo_url        = "${var.neo_url}"
      neo_user       = "${var.neo_user}"
      neo_password   = "${var.neo_password}"
   }
}

data "template_file" "celery_task" {
   template = "${file("task-definitions/celery.json")}"

   vars {
      neo_url        = "${var.neo_url}"
      neo_user       = "${var.neo_user}"
      neo_password   = "${var.neo_password}"
      redis_url      = "${var.redis_url}"
      datacite_url   = "${var.datacite_url}"
   }
}

data "template_file" "nginx_task" {
   template = "${file("task-definitions/nginx.json")}"

   vars {
      wsgi_dns       = "${var.wsgi_dns}"
      wsgi_port      = "${var.wsgi_port}"
      bagit_dns      = "${var.bagit_dns}"
      bagit_port     = "${var.bagit_port}"
   }
}
