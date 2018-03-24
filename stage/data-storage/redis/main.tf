resource "aws_elasticache_cluster" "redis-stage" {
  cluster_id               = "redis-stage"
  engine                   = "redis"
  engine_version           = "2.8.23"
  node_type                = "cache.m4.large"
  port                     = 6379
  num_cache_nodes          = 1
  parameter_group_name     = "${aws_elasticache_parameter_group.redis-stage.name}"
  security_group_ids       = ["${data.aws_security_group.datacite-private.id}"]
  subnet_group_name        = "${aws_elasticache_subnet_group.redis-stage.name}"
  apply_immediately        = true
  snapshot_retention_limit = 8
  snapshot_window          = "00:30-01:30"
}

resource "aws_elasticache_subnet_group" "redis-stage" {
  name        = "redis-stage"
  description = "Elasticache redis-stage subnet group"

  subnet_ids = [
    "${aws_subnet.datacite-private.id}",
    "${aws_subnet.datacite-alt.id}"
  ]
}

resource "aws_elasticache_parameter_group" "redis-stage" {
    name = "redis-stage"
    family = "redis2.8"
    description = "Cache cluster redis-stage param group"

    parameter {
        name = "activerehashing"
        value = "yes"
    }

    parameter {
        name = "min-slaves-to-write"
        value = "0"
    }
}

resource "aws_route53_record" "redis-test" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "redis1.test.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"
  records = ["${aws_elasticache_cluster.redis-stage.cache_nodes.0.address}"]
}
