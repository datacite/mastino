resource "aws_elasticache_cluster" "redis" {
  cluster_id               = "redis"
  engine                   = "redis"
  engine_version           = "2.8.23"
  node_type                = "cache.m4.large"
  port                     = 6379
  num_cache_nodes          = 1
  parameter_group_name     = "${aws_elasticache_parameter_group.redis.name}"
  security_group_ids       = ["${data.aws_security_group.datacite-private.id}"]
  subnet_group_name        = "${aws_elasticache_subnet_group.redis.name}"
  apply_immediately        = true
  snapshot_retention_limit = 8
  snapshot_window          = "00:30-01:30"
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "redis"
  description = "Elasticache redis subnet group"

  subnet_ids = [
    "${data.aws_subnet.datacite-private.id}",
    "${data.aws_subnet.datacite-alt.id}"
  ]
}

resource "aws_elasticache_parameter_group" "redis" {
    name = "redis"
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

resource "librato_space" "redis" {
    name = "Redis"
}

resource "aws_route53_record" "redis" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "redis1.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"
  records = ["${aws_elasticache_cluster.redis.cache_nodes.0.address}"]
}

resource "librato_space_chart" "redis-network" {
  name = "Redis Network Traffic"
  space_id = "${librato_space.redis.id}"
  type = "line"

  stream {
    metric = "AWS.ElastiCache.NetworkBytesIn"
    source = "eu-west-1.redis.0001"
  }
  stream {
    metric = "AWS.ElastiCache.NetworkBytesOut"
    source = "eu-west-1.redis.0001"
  }
}
