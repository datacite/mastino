resource "aws_elasticsearch_domain" "default" {
  domain_name           = "elasticsearch"
  elasticsearch_version = "6.3"
  cluster_config {
    instance_type = "m4.2xlarge.elasticsearch"
    instance_count = 2
    zone_awareness_enabled = true
  }

  advanced_options {
    rest.action.multi.allow_explicit_index = "true"
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ebs_options{
      ebs_enabled = true
      volume_type = "gp2"
      volume_size = 300
  }

  vpc_options {
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.elasticsearch.arn}"
    log_type                 = "INDEX_SLOW_LOGS"
  }

  tags {
    Domain = "elasticsearch"
  }

  // lifecycle {
  //   prevent_destroy = "true"
  // }
}

resource "aws_elasticsearch_domain_policy" "default" {
  domain_name = "${aws_elasticsearch_domain.default.domain_name}"

  access_policies = "${file("elasticsearch_policy.json")}"
}

resource "aws_cloudwatch_log_group" "elasticsearch" {
  name = "elasticsearch"
}

resource "aws_cloudwatch_log_resource_policy" "elasticsearch" {
  policy_name = "elasticsearch"
  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_route53_record" "elasticsearch" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "elasticsearch.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${aws_elasticsearch_domain.default.endpoint}"]
}